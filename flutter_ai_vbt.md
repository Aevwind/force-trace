# 🏋️‍♂️ VeloxFit —— 基于 Flutter 与计算机视觉的 VBT 智能健身记录应用
**产品需求与技术架构说明书 (PRD & Technical Architecture Specification)**

* **文档版本**：v1.0.0
* **核心数据底座**：`hasaneyldrm/exercises-dataset` (1,324 个多语言结构化动作库)
* **客户端技术栈**：Flutter 3.x (Dart 3) + Native C++/FFI (端侧视觉推理)
* **目标平台**：iOS (14.0+) / Android (API 26+)

---

## 1. 项目背景与产品定位

传统健身记录应用（如 Strong、Hevy）仅能静态记录“重量 × 次数”，无法感知训练者的动作质量与神经肌肉疲劳度；而专业 VBT（Velocity-Based Training，基于速度的力量训练）硬件传感器（如 GymAware、Vitruvian）价格高昂且携带不便。

本应用旨在将 **`exercises-dataset` 的 1,324 个标准化多语言健身动作库** 与 **端侧 AI 计算机视觉 VBT 追踪引擎** 深度融合，打造一款无需外接硬件、仅凭手机摄像头即可实现**实时动作速度监测、杠铃轨迹绘制、关节角度评估与智能容量记录**的全能型健身辅导应用。

---

## 2. 系统总体技术架构与技术栈选型

为保证移动端在实时运行“人体姿态估计 + 杠铃目标追踪”双模型的同时，UI 依然维持 **30~60 FPS** 的丝滑渲染，系统采用 **“主 UI 线程 + Dart 后台 Isolate 解算 + Native C++/GPU 推理”** 的三层异步解耦架构。

### 2.1 核心技术栈清单 (Tech Stack)

| 架构分层 | 推荐技术 / 依赖库 | 核心职责与选型理由 |
| :--- | :--- | :--- |
| **应用框架与状态管理** | `Flutter 3.24+` + `Riverpod 2.x` (`flutter_riverpod`) | 响应式状态管理，支持高频传感器/视觉流数据的局部 Widget 精准刷新，避免全屏重绘。 |
| **本地数据库 (ORM)** | `Drift` (基于 `sqlite3`) | 强类型响应式 SQLite 封装，支持直接导入 `exercises-dataset` 的 1,324 条动作数据，支持复杂 SQL 聚合查询（计算肌群容量、1RM 趋势）。 |
| **相机流与帧提取** | `camerax` / `camera` + Native `ImageReader` / `AVCaptureVideoDataOutput` | 直接在原生层拦截 YUV420 / BGRA 相机帧送入 NPU/GPU 推理，**严禁将完整图像帧通过 MethodChannel 传回 Dart 层**（避免内存拷贝卡顿），仅向 Dart 层回传 5 个关键坐标点。 |
| **通道 A：骨骼姿态推理** | `MediaPipe Pose Landmarker` (或 Apple `Vision` / Android `ML Kit`) | 实时提取人体 33 个关键点，重点锁定侧面 **肩、髋、膝、踝** 4 个关节点二维像素坐标 $(x, y)$ 及可见度置信度。 |
| **通道 B：杠铃端面追踪** | `YOLOv8n-pose/det` (部署于 `NCNN` / `TFLite` GPU Delegate / `CoreML`) + `ByteTrack` | 专门针对标准奥运杠铃片端面（直径 450mm）微调的轻量级检测模型，配合卡尔曼滤波与光流法实现 60FPS 中心点 $(bx, by)$ 锁定。 |
| **信号滤波与状态机** | Dart `Isolate` + `One-Euro Filter` (一欧元滤波器) | 在独立线程中平滑骨骼与杠铃坐标抖动，运行“静止/离心/折返/向心”有限状态机（FSM），实时计算瞬时速度、ROM 与关节夹角。 |
| **实时 HUD 与轨迹渲染** | Flutter `CustomPainter` + `Canvas` | 零组件开销的高性能自绘引擎，直接绘制骨骼连线、双色杠铃轨迹线、实时速度/角度动态波形图。 |
| **图表与组后报告** | `fl_chart` | 渲染组后结算页面的逐次平均速度柱状图、负荷-速度曲线（LVP）与历史容量折线图。 |
| **视频带 HUD 合成导出** | 原生硬编码合成 (`MediaCodec` / `AVAssetWriter`) 或 `ffmpeg_kit_flutter_full_gpl` | 将相机原始视频流与 Flutter 离屏渲染的 HUD 图层合成为带数据看板的 1080p MP4 视频。 |
| **语音播报辅导** | `flutter_tts` + `audioplayers` | 训练中实时播报次数、深度不足警告（如“蹲得太浅”）以及达到速度损失率（VL）阈值时的停组蜂鸣提示。 |

### 2.2 端侧实时数据流转架构图

```text
[手机摄像头 30/60 FPS] 
       │ (Zero-Copy GPU Texture / Native Buffer)
       ▼
┌──────────────────────────────────────────────────────────┐
│ Native C++ / 平台层 (iOS Metal / Android Vulkan/NNAPI)    │
│  ├─ 通道 A: MediaPipe Pose ➔ 提取 [肩, 髋, 膝, 踝] 坐标   │
│  └─ 通道 B: YOLOv8-nano + ByteTrack ➔ 提取 [杠铃中心] 坐标│
└──────────────────────────┬───────────────────────────────┘
                           │ (通过 Dart FFI / EventChannel 仅传输 ~64 Bytes/帧 的浮点数组)
                           ▼
┌──────────────────────────────────────────────────────────┐
│ Dart Background Isolate (运动学解算引擎)                  │
│  1. One-Euro Filter 坐标去噪平滑                          │
│  2. 像素-物理比例尺换算 (k = 0.45m / 杠铃片像素直径)       │
│  3. 关节向量点积计算 ➔ 实时髋角 θ_hip、膝角 θ_knee         │
│  4. 周期状态机切分 ➔ [静止] ➔ [离心] ➔ [底部折返] ➔ [向心] │
│  5. 结算单次 Rep 数据: Mean V, Peak V, ROM, 耗时, VL%     │
└──────────────────────────┬───────────────────────────────┘
                           │ (Stream<KinematicsFrameState>)
                           ▼
┌──────────────────────────────────────────────────────────┐
│ Flutter UI Thread (60 FPS 高刷渲染层)                     │
│  ├─ AR 骨骼与杠铃轨迹画布 (CustomPainter)                 │
│  ├─ 左侧四宫格毛玻璃 HUD 仪表盘 (速度/角度波形、轨迹矩阵)   │
│  └─ 组后结算页 (9 REPS 速度柱状图 + ROM/VL 明细表 + 导出) │
└──────────────────────────────────────────────────────────┘
```

---

## 3. 核心业务功能详细需求

### 3.1 模块一：`exercises-dataset` 融合与分级动作库
1. **多语言数据清洗与离线预置**：
   * 提取 `exercises-dataset` 中的 `data/exercises.json`，在打包阶段将其编译为预置 SQLite 数据库文件（`assets/db/veloxfit_init.db`）。
   * 默认展示中文（`zh`）动作名称与 `instruction_steps` 分步指南，支持在设置中一键切换英文（`en`）等 10 种语言。
2. **媒体资源缺失合规解决方案**：
   * 鉴于原仓库已清理 `Gym Visual` 版权图片/GIF，动作列表页采用 **SVG 人体肌肉解剖高亮组件**（根据动作的 `target` 主肌群染亮红色，`secondary_muscles` 协同肌群染亮橙色）作为默认视觉图标。
   * 支持用户在本地为任意动作录制并绑定自己的标准示范视频。
3. **三级视觉赋能映射体系（Tier 1 ~ Tier 3）**：
   * **Tier 1（VBT + 骨骼双通道追踪，约 45 个核心自由重量杠铃动作）**：涵盖杠铃深蹲、传统硬拉、罗马尼亚硬拉、杠铃卧推、站姿杠铃推举、杠铃划船等。开启完整四宫格 HUD 与杠铃轨迹追踪。
   * **Tier 2（纯骨骼姿态与节奏追踪，约 250 个自重/哑铃动作）**：涵盖引体向上、俯卧撑、哑铃弯举、箭步蹲等。隐藏“杠铃轨迹”与“物理速度”卡片，仅展示**自动计数、离心/向心节奏比（Tempo）、核心关节角波形图**。
   * **Tier 3（常规器械与孤立动作，其余约 1,029 个动作）**：提供标准的多语言图文指南、组间休息倒计时与传统容量（重量 × 次数 × RPE）打点记录。

---

### 3.2 模块二：训练前空间标定与机位引导
1. **自动比例尺标定（Auto-Calibration）**：
   * **标准片标定法（默认）**：检测画面中直径为 **450mm** 的标准奥运杠铃片像素包围盒宽度 $D_{\text{pixel}}$，自动计算物理转换系数 $k = \frac{0.45}{D_{\text{pixel}}}\ (\text{m/pixel})$。
   * **自定义杠铃片/身高标定法**：若用户在家庭健身房使用非标小杠铃片，支持手动输入杠铃片直径（如 `280mm`）或利用用户身高进行站立姿态标定。
2. **机位合规性自检（Camera Setup Assistant）**：
   * 识别人体关键点完整性：要求肩、髋、膝、踝及杠铃端面同时出现在取景框内，置信度均 $> 0.75$。
   * 侧面角度校验：通过左右肩/左右髋的水平像素重叠度，判断手机是否处于正侧面（偏差 $\le 15^\circ$），达标后边框由红变绿并语音提示“机位已就绪，请开始训练”。

---

### 3.3 模块三：训练中实时 HUD 视觉看板（1:1 复刻与增强）
画面采用全屏相机预览作为底层，支持前后摄像头切换，上层叠加 **AR 骨骼轨迹画布** 与 **左侧四宫格毛玻璃悬浮窗（BackdropFilter Blur）**：

#### A. 右侧主画面 AR 实时绘制层
* **人体运动链渲染**：用白色实线（线宽 `3.0`）连接肩、髋、膝、踝，关节点绘制外白内黑圆环锚点；在髋关节和膝关节夹角内侧绘制半透明扇形弧线，并实时标注当前角度（如 `160°`、`165°`）。
* **杠铃双色动态轨迹**：
  * 实时连接当前动作周期内杠铃中心点的历史坐标队列。
  * **离心阶段（下放）**：绘制 **亮绿色** 平滑贝塞尔曲线。
  * **向心阶段（发力蹲起/推起）**：绘制 **橙红色** 平滑贝塞尔曲线。
  * 每次新动作离心开始时，自动将上一次动作的轨迹移入左下角缩略图矩阵，清空主画面旧轨迹。
* **杠铃头顶速度胶囊**：跟随杠铃中心点 $(bx_t, by_t - 60\text{px})$ 绘制圆角黑底半透明胶囊框，以橙色粗体实时显示当前瞬时速度（如 `0.65 m/s`）。

#### B. 左侧四宫格 HUD 数据仪表盘
1. **卡片 1：动作进度与平均速度总览**
   * 顶部显示动作名称（如 `深蹲`）。
   * 中部显示当前组完成进度（如 `5/9`）。
   * 底部大号荧光绿字体展示刚完成那一次动作的向心平均速度（如 `0.71` `Mean V (m/s)`）。
2. **卡片 2：单次速度实时波形图**
   * 标题栏：`速度: 次X · 耗时s`（如 `速度: 次5 · 2.7s`）。
   * 状态副标题：实时进行中显示当前速度与状态标签（`静止` / `离心` / `向心`）；向心阶段刚结束时，左侧锁定显示本次向心峰值速度（如 `峰值 0.92 m/s`）。
   * 波形图：Y 轴固定范围 `0 ~ 1.5 m/s`，X 轴随当前次数持续时间动态延展，绘制绿色速度曲线及底部绿色渐变填充。
3. **卡片 3：双关节角度动态波形图**
   * 标题栏：`角度: 次X · 耗时s`。
   * 副标题：绿色字体显示 `髋角 62°`，浅灰白色字体显示 `膝角 84°`。
   * 波形图：Y 轴范围 `45° ~ 180°`，同步绘制 **绿色实线（髋角轨迹）** 与 **白色虚线（膝角轨迹）**，清晰呈现底部折返谷值与髋膝同步率。
4. **卡片 4：杠铃轨迹缩略图矩阵**
   * 标题栏：`杠铃轨迹`。
   * 采用每行 6 列的网格布局，将每一次已完成的动作轨迹等比归一化缩放后存入网格（保留绿色离心线、白色向心线及底部折返圆点）。
   * 下方标注序号（`1`~`9`），并根据整组最高 `Mean V`（且 ROM 达标）自动在对应序号旁标记星号（如 `1★`）。

---

### 3.4 模块四：组后总结报告与智能负荷分析
当用户将杠铃放回挂钩（状态机检测到水平回架位移并持续静止 $> 3\text{s}$）或手动点击结束时，自动弹出全屏黑底总结报告页：
1. **头部概览**：应用 Logo、动作大标题（`深蹲`）、完成总次数（`9 REPS`）、日期时间。
2. **左半区：逐次平均速度柱状图**：
   * 展示第 1 至第 N 次的垂直绿色柱状图，柱体顶部显示具体 `Mean V` 数值（如 `0.83`, `0.78`, `0.70`...），直观反映体力消耗与尾次冲刺情况。
3. **右半区：生物力学明细表**：
   * 包含四列：`次`（`01`~`09`）、`ROM`（厘米，如 `87.0`、`66.1`）、`速度`（m/s，如 `0.83`）、`VL`（速度损失率，基准最佳次显示 `-`，其余显示相对衰减百分比如 `-6%`、`-16%`）。
   * 最佳次数所在行（如 `01`）整行采用荧光绿高亮显示。
4. **今日 1RM 预测与疲劳度建议（进阶 VBT 功能）**：
   * 根据用户输入的本组杠铃负重（如 `100kg`）与本组最快平均速度（`0.83 m/s`），结合标准深蹲最小极限速度阈值（MVT $\approx 0.30\text{ m/s}$），通过负荷-速度线性回归实时估算当日 1RM 状态。

---

## 4. 数据库 Schema 详细设计 (Drift / SQLite)

在 Flutter 工程中，使用 `drift` 定义以下 4 张核心表，实现 `exercises-dataset` 与 VBT 业务数据的无缝关联：

```dart
import 'package:drift/drift.dart';

// 1. 动作百科主表 (由 exercises-dataset 导入)
class Exercises extends Table {
  TextColumn get id => text()();                           // 数据集原始唯一ID
  TextColumn get nameEn => text()();                       // 英文名称
  TextColumn get nameZh => text()();                       // 中文名称
  TextColumn get category => text()();                     // 分类 (legs, chest, back...)
  TextColumn get equipment => text()();                    // 器械 (barbell, dumbbell, body weight...)
  TextColumn get targetMuscle => text()();                 // 主发力肌群
  TextColumn get secondaryMusclesJson => text()();         // 协同肌群 JSON 数组
  TextColumn get instructionsZhJson => text()();           // 中文分步指南 JSON 数组
  IntColumn get trackingTier => integer().withDefault(const Constant(3))(); // 1: VBT+姿态, 2: 仅姿态, 3: 常规记录
  
  @override
  Set<Column> get primaryKey => {id};
}

// 2. 动作视觉追踪参数配置表 (针对 Tier 1 & Tier 2 动作预设)
class ExerciseCvConfigs extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get cameraView => text().withDefault(const Constant('side'))(); // 'side' 正侧面 / 'front45'
  TextColumn get primaryJointsJson => text()();            // 例如 '["hip", "knee"]' 或 '["elbow", "shoulder"]'
  TextColumn get eccentricDirection => text()();           // 离心方向: 'down' (深蹲/卧推) 或 'up' (下拉)
  RealColumn get minRomCm => real().withDefault(const Constant(30.0))();     // 最小有效位移阈值 (cm)
  RealColumn get mvtVelocity => real().withDefault(const Constant(0.30))();  // 该动作极限重量最小速度阈值 (m/s)

  @override
  Set<Column> get primaryKey => {exerciseId};
}

// 3. 训练组记录表 (Workout Sets)
class WorkoutSets extends Table {
  TextColumn get setId => text()();                        // UUID
  TextColumn get exerciseId => text().references(Exercises, #id)();
  RealColumn get weightKg => real()();                     // 负重 (kg)
  IntColumn get targetReps => integer()();                 // 目标次数 (如 9)
  IntColumn get completedReps => integer()();              // 实际完成次数 (如 9)
  RealColumn get bestMeanV => real().nullable()();         // 本组最快向心平均速度 (m/s)
  RealColumn get maxVelocityLossPct => real().nullable()();// 本组最大速度衰减率 (%)
  TextColumn get exportedVideoPath => text().nullable()(); // 合成导出的视频路径
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {setId};
}

// 4. 单次动作生物力学明细表 (Workout Reps)
class WorkoutReps extends Table {
  TextColumn get repId => text()();                        // UUID
  TextColumn get setId => text().references(WorkoutSets, #setId)();
  IntColumn get repIndex => integer()();                   // 序号 (1 ~ 9)
  RealColumn get durationSec => real()();                  // 单次总耗时 (如 4.0s)
  RealColumn get romCm => real()();                        // 向心垂直位移幅度 (如 87.0 cm)
  RealColumn get meanVelocity => real()();                 // 向心平均速度 (如 0.83 m/s)
  RealColumn get peakVelocity => real()();                 // 向心峰值速度 (如 1.15 m/s)
  RealColumn get velocityLossPct => real()();              // 相对最佳次的速度损失率 (如 -16.0)
  RealColumn get minHipAngle => real().nullable()();       // 底部最小髋角 (如 43.0°)
  RealColumn get minKneeAngle => real().nullable()();      // 底部最小膝角 (如 57.0°)
  BoolColumn get isBestRep => boolean().withDefault(const Constant(false))(); // 是否标记 ★
  TextColumn get trajectoryJson => text()();               // 归一化轨迹点序列 [{x, y, phase}]
  TextColumn get telemetryCurveJson => text()();           // 速度与双角度时序波形数组

  @override
  Set<Column> get primaryKey => {repId};
}
```

---

## 5. 核心运动学算法与状态机实现 (Dart 核心代码规范)

### 5.1 关节夹角计算与物理速度解算 (`KinematicsCalculator`)

```dart
import 'dart:math' as math;
import 'dart:ui';

class KinematicsCalculator {
  /// 计算三个二维坐标点构成的关节夹角 (单位: 度 0°~180°)
  /// 例如计算髋角: a = 肩(Shoulder), b = 髋(Hip, 顶点), c = 膝(Knee)
  static double calculateJointAngle(Offset a, Offset b, Offset c) {
    final double abX = a.dx - b.dx;
    final double abY = a.dy - b.dy;
    final double cbX = c.dx - b.dx;
    final double cbY = c.dy - b.dy;

    final double dotProduct = (abX * cbX) + (abY * cbY);
    final double magAB = math.sqrt(abX * abX + abY * abY);
    final double magCB = math.sqrt(cbX * cbX + cbY * cbY);

    if (magAB == 0 || magCB == 0) return 180.0;

    final double cosAngle = (dotProduct / (magAB * magCB)).clamp(-1.0, 1.0);
    final double angleRad = math.acos(cosAngle);
    return angleRad * (180.0 / math.pi);
  }

  /// 计算杠铃瞬时物理速度 (m/s) 与垂直带符号速度
  /// [prevPos], [currPos]: 像素坐标; [scaleMetersPerPixel]: 比例尺 k; [dtSeconds]: 帧时间差
  static ({double speed, double vy}) calculateBarbellVelocity(
    Offset prevPos,
    Offset currPos,
    double scaleMetersPerPixel,
    double dtSeconds,
  ) {
    if (dtSeconds <= 0) return (speed: 0.0, vy: 0.0);
    final double dxMeters = (currPos.dx - prevPos.dx) * scaleMetersPerPixel;
    // 屏幕坐标系 Y 轴向下为正，因此向上蹲起时 (prevPos.dy - currPos.dy) > 0
    final double dyMeters = (prevPos.dy - currPos.dy) * scaleMetersPerPixel;
    final double distanceMeters = math.sqrt(dxMeters * dxMeters + dyMeters * dyMeters);

    return (
      speed: distanceMeters / dtSeconds,
      vy: dyMeters / dtSeconds, // vy > 0 代表向上运动, vy < 0 代表向下运动
    );
  }
}
```

### 5.2 动作周期有限状态机 (`VbtRepStateMachine`)

```dart
enum RepPhase { idle, eccentric, concentric }

class VbtRepStateMachine {
  RepPhase currentPhase = RepPhase.idle;
  
  // 速度与位移判据阈值
  static const double velocityThreshold = 0.06; // 脱离静止的速度阈值 (m/s)
  static const double minRomMeters = 0.30;      // 最小有效深蹲幅度 (30 cm)

  double _repStartTime = 0;
  double _bottomY = 0;
  double _topStartY = 0;
  final List<double> _concentricVelocities = [];

  /// 每帧输入垂直物理坐标 yMeters (向上为正) 与垂直速度 vy (m/s)
  void updateFrame({
    required double timestampSec,
    required double yMeters,
    required double vy,
    required double instantaneousSpeed,
    required void Function(double meanV, double peakV, double romCm, double duration) onRepCompleted,
  }) {
    switch (currentPhase) {
      case RepPhase.idle:
        // 检测到持续向下运动 -> 进入离心阶段 (Eccentric)
        if (vy < -velocityThreshold) {
          currentPhase = RepPhase.eccentric;
          _repStartTime = timestampSec;
          _topStartY = yMeters;
          _bottomY = yMeters;
          _concentricVelocities.clear();
        }
        break;

      case RepPhase.eccentric:
        if (yMeters < _bottomY) {
          _bottomY = yMeters; // 持续刷新底部最低点
        }
        // 速度由负转正且超过阈值 -> 经过底部折返点，进入向心阶段 (Concentric)
        if (vy > velocityThreshold && (_topStartY - _bottomY) >= minRomMeters * 0.5) {
          currentPhase = RepPhase.concentric;
          _concentricVelocities.add(instantaneousSpeed);
        } else if (vy.abs() < 0.02 && (_topStartY - _bottomY) < 0.15) {
          // 轻微晃动未构成有效下蹲，重置回静止
          currentPhase = RepPhase.idle;
        }
        break;

      case RepPhase.concentric:
        if (vy > 0.02) {
          _concentricVelocities.add(instantaneousSpeed);
        }
        // 回到顶部且速度趋近于 0 -> 结算本次动作
        if (vy.abs() < velocityThreshold) {
          final double romMeters = yMeters - _bottomY;
          if (romMeters >= minRomMeters && _concentricVelocities.isNotEmpty) {
            final double meanV = _concentricVelocities.reduce((a, b) => a + b) / _concentricVelocities.length;
            final double peakV = _concentricVelocities.reduce((a, b) => a > b ? a : b);
            final double duration = timestampSec - _repStartTime;
            onRepCompleted(meanV, peakV, romMeters * 100.0, duration);
          }
          currentPhase = RepPhase.idle;
        }
        break;
    }
  }
}
```

---

## 6. Flutter 工程目录结构规范 (Feature-First Architecture)

```text
lib/
├── main.dart
├── core/
│   ├── database/
│   │   ├── app_database.dart          # Drift 数据库定义与迁移逻辑
│   │   └── dataset_seeder.dart        # 解析 exercises.json 并初始化 Tier 1~3 标签
│   ├── cv_engine/
│   │   ├── native_vision_bridge.dart  # FFI / EventChannel 接收原生端双通道坐标
│   │   ├── one_euro_filter.dart       # 坐标平滑防抖滤波器
│   │   ├── kinematics_calculator.dart # 角度、比例尺与物理速度计算
│   │   └── vbt_state_machine.dart     # 静止/离心/向心状态机
│   └── utils/
│       └── video_exporter.dart        # HUD 画布录制与 MP4 硬件合成导出
├── features/
│   ├── exercise_catalog/              # 1,324 个动作百科模块
│   │   ├── ui/
│   │   │   ├── catalog_screen.dart
│   │   │   └── widgets/muscle_svg_avatar.dart # 替代缺失GIF的SVG肌肉高亮图
│   │   └── providers/
│   ├── vbt_tracker/                   # AI 视觉实时追踪核心模块
│   │   ├── models/telemetry_frame.dart
│   │   ├── providers/vbt_session_provider.dart
│   │   └── ui/
│   │       ├── vbt_camera_screen.dart
│   │       ├── painters/
│   │       │   ├── ar_skeleton_barbell_painter.dart # 右侧主画面骨骼与双色轨迹绘制
│   │       │   ├── live_waveform_painter.dart       # 左侧速度与双关节角实时波形绘制
│   │       │   └── mini_trajectory_painter.dart     # 左下角 1~9 次轨迹缩略图绘制
│   │       └── widgets/hud_glass_card.dart          # 毛玻璃悬浮卡片封装
│   └── workout_summary/               # 组后结算报告与历史分析模块
│       └── ui/
│           ├── post_set_summary_screen.dart         # 9 REPS 速度柱状图 + ROM/VL 明细表
│           └── load_velocity_profile_chart.dart     # 1RM 负荷-速度曲线预测页
```

---

## 7. 研发里程碑与迭代计划 (Milestones)

* **Phase 1：数据基座与动作百科（第 1~2 周）**
  * 编写脚本清洗 `hasaneyldrm/exercises-dataset` 的 `exercises.json`，为所有杠铃复合动作打上 `Tier 1` 标记，构建离线 SQLite 数据库。
  * 完成动作库搜索、多语言切换、SVG 肌群高亮展示与常规训练容量记录功能。
* **Phase 2：端侧视觉双通道打通与状态机联调（第 3~5 周）**
  * 集成 `MediaPipe Pose` 与杠铃端面 `YOLOv8n` 检测模型，打通原生层到 Dart Isolate 的坐标流传输。
  * 实现 450mm 标准杠铃片自动标定算法与 `VbtRepStateMachine` 离心/向心切分逻辑。
* **Phase 3：HUD 实时看板与组后报告复刻（第 6~7 周）**
  * 使用 `CustomPainter` 1:1 还原视频中的骨骼角度扇形标注、杠铃红绿轨迹线、左侧四宫格毛玻璃动态曲线面板及组后黑底结算页。
* **Phase 4：带 HUD 视频导出与性能优化（第 8 周）**
  * 实现训练回放与一键合成导出带 HUD 数据的分享视频，完成高低端机型的发热与帧率稳定性压测。