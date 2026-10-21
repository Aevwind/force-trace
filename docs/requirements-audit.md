# 需求文档对照审计（v1.0.0）

审计日期：2026-10-21  
审计对象：`flutter_ai_vbt.md`（2026-10-21 01:50 修订版） vs. `F:\github\force-trace` 现有实现  
状态说明：✅ 已覆盖　🟡 部分覆盖/实现方式不同　❌ 未实现

## 结论摘要

- **已覆盖**：1,324 动作/10 语言离线库、Tier 分级、动作详情与 `flutter_body_atlas` 交互图谱、今日计划、训练历史、组后报告、One-Euro、四态状态机、VBT 指标、Android/Web 构建、真机调试。
- **本轮新增**：Android/iOS 端 **ML Kit Pose Landmarker 真实姿态推理**（Web 保持模拟源），相机图像流 → 33 关键点 → 现有 VBT 引擎；真实姿态用于骨架、角度、计数与参考点速度。
- **关键缺口**：杠铃端面 YOLOv8 检测、真实杠铃片自动标定、Tier 数量/分层与文档不一致、Tier 2 专属 HUD、1RM/LVP、带 HUD 视频导出、原生零拷贝/FFI + Isolate、iOS 构建、相机机位自检与前后摄切换。
- 因此当前版本可以称为 **“真实人体姿态推理 + 杠铃参考点近似 VBT”**，还不能称为文档所描述的 **“骨骼 + 杠铃双通道原生推理”**。

---

## 1. 系统架构与技术栈

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| Flutter 3.24+ / Riverpod 2.x | ✅ | Flutter 3.47.7、Riverpod 2.6.1 |
| Drift / SQLite 1,324 动作 | ✅ | 预置 SQLite（`initial_exercises.db.gz`），Drift 2.35.2；文件命名与文档 `veloxfit_init.db` 不同 |
| 相机流 + 原生 ImageReader/AVCapture，禁止整帧过 MethodChannel | 🟡 | `camera` 插件 + preview + `startImageStream`；**整帧仍会进入 Dart 并经 Platform Channel 交给 ML Kit**，不是原生零拷贝 |
| 通道 A：MediaPipe / Apple Vision / Android ML Kit，33 点 | ✅ | ML Kit Pose Landmarker（base/stream）已接入；iOS 代码路径存在但当前 Windows 环境未构建 |
| 通道 B：YOLOv8n-pose/det + ByteTrack | ❌ | 未接入任何杠铃端面检测模型；用**手腕/肩部/髋部参考点**近似杠铃或身体位移 |
| Dart Isolate + One-Euro | 🟡 | One-Euro 在引擎内实现；引擎由 30 Hz Timer 驱动，未独立 Isolate |
| CustomPainter HUD | ✅ | 骨架、关节角扇形、双色轨迹、速度胶囊、四张指标卡 |
| fl_chart 报告 | ✅ | 逐次 Mean V 柱状图、VL 阈值线、最佳标记 |
| 视频带 HUD 合成 | ❌ | 无 MediaCodec/AVAssetWriter/ffmpeg，未实现导出 |
| flutter_tts + audioplayers | 🟡 | flutter_tts 已接入；audioplayers/蜂鸣音效未接入 |
| 30~60 FPS | 🟡 | UI Timer 30 Hz；ML Kit 实际推理 FPS 依设备，未做性能基准 |

## 2. 数据底座与动作库（3.1）

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| `data/exercises.json` 离线编译 SQLite | ✅ | `tool/build_exercises_dataset.py` 生成预置库 |
| 1,324 动作、10 语言 | ✅ | 已验证 1,324 行、10 语言教程 |
| 中文默认、设置切换英文等 10 语言 | ✅ | 中/英 UI；动作步骤按语言读取 |
| SVG 肌肉高亮（主红/协同橙） | 🟡 | 已升级为 `flutter_body_atlas` 交互图谱；主肌群用品牌**绿色**、协同橙色，而非文档红色 |
| 本地为标准动作录制并绑定示范视频 | ❌ | 未实现 |
| Tier 1≈45 / Tier 2≈250 / Tier 3≈1,029 | ❌ | 实际 **76 / 920 / 328**，分层规则与文档不一致，Tier 3 偏少、Tier 2 偏多 |
| Tier 1 双通道完整 HUD | 🟡 | HUD 有骨架/轨迹/速度；无真实杠铃检测 |
| Tier 2 纯姿态、隐藏杠铃与物理速度，展示计数/Tempo/角度波形 | ❌ | 目前按动作名称推断 `MotionPattern`，未按 Tier 2 隐藏物理速度卡；无 Tempo/双角度波形卡 |
| Tier 3 图文指南 + 组间休息 + 容量记录 | ✅ | 已有图文、休息计时、SetLogs |

## 3. 训练前标定（3.2）

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| 450 mm 杠铃片自动检测，`k = 0.45 / D_pixel` | ❌ | 标定页“自动识别”是演示：固定 `120px ± 1.8`、confidence 0.96 |
| 自定义片径/身高标定 | 🟡 | 片径手动 35/45/50；**身高标定已改为相机 + ML Kit 鼻-踝像素高度**（需全身入镜，标定页实时显示像素高度）；片径自动检测仍是演示。无人/无片径时提供「使用默认标定」出口，避免卡死 |
| 肩/髋/膝/踝/杠铃片同时入镜，置信度 >0.75 | ❌ | 未实现置信度门槛/缺帧提示；仅在 ML Kit 映射层要求肩/髋/膝/踝齐全 |
| 侧面角度校验（肩髋重叠度，偏差≤15°） | ❌ | 仅有手机倾角传感器（陀螺仪），没有人体侧面角度校验 |
| 边框红转绿 + 语音“机位已就绪” | ❌ | 标定页始终是装饰性场景，无真实边界/语音 |

## 4. 实时 HUD（3.3）

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| 全屏相机预览、前后摄切换 | ✅ | 预览层 + HUD 顶栏前后摄切换；前置摄像头已真机验证 |
| 白色骨架、关节点、髋/膝角扇形 | ✅ | `HudPainter` 已实现 |
| 杠铃双色轨迹（离心绿/向心橙红），每次重置 | ✅ | 用参考点绘制轨迹；颜色与阶段切换已有 |
| 杠铃头顶速度胶囊 | ✅ | 跟随参考点绘制速度胶囊 |
| 卡片 1：名称/进度/本次 Mean V | ✅ | 当前四卡中的次数/平均速度等 |
| 卡片 2：单次速度波形 + 状态/峰值 | ❌ | 当前为平均/峰值数字卡，无速度时序波形 |
| 卡片 3：髋/膝双角度波形（45~180°） | ❌ | 有实时角度数字与扇形，无波形卡 |
| 卡片 4：每行 6 列轨迹缩略图矩阵 + ★ | ❌ | 只有主舞台当前/上一组轨迹，无 6 列矩阵 |
| 放回杠铃/回架检测，静止 >3s 自动结束 | ❌ | 只有手动结束 + VL 自动停组 |

## 5. 组后报告（3.4）

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| Logo/动作/次数/日期头部 | ✅ | 报告页已有 |
| 逐次 Mean V 柱状图 + 数值 | ✅ | fl_chart 柱状图、最佳高亮 |
| ROM/速度/VL 明细表 | ✅ | 最佳次数/逐次明细 |
| 最佳行荧光绿 | ✅ | 已有 |
| 1RM 预测 + 疲劳建议 | ❌ | 无 MVT/负荷-速度回归/1RM 页面 |
| 负荷-速度曲线（LVP） | ❌ | 无 |

## 6. 数据库 Schema（4）

| 文档表/字段 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| `Exercises`（nameEn/nameZh/instructionsZhJson/trackingTier） | 🟡 | `exercises` + `exercise_details`，字段名不同；功能等价 |
| `ExerciseCvConfigs` | ❌ | 无该表；`MotionPattern`/ROM 阈值写在 Dart 代码 |
| `WorkoutSets`（UUID/exportedVideoPath） | 🟡 | `workout_sessions` 自增 ID、无 UUID/exportedVideoPath |
| `WorkoutReps`（trajectoryJson/telemetryCurveJson） | ❌ | `rep_records` 无轨迹/波形 JSON；报告只存聚合指标 |
| 计划/容量记录 | ✅（额外） | `plan_items`、`set_logs` 为文档未列出的扩展 |

## 7. 运动学算法（5）

| 文档要求 | 状态 | 现有实现 / 差距 |
| --- | --- | --- |
| 三点夹角公式 | ✅ | `angles.dart`，有测试 |
| 速度/垂直速度 | ✅ | One-Euro + 物理比例尺 |
| 四态状态机 | ✅ | `rep_state_machine.dart`，阈值/ROM 可配，测试覆盖 |
| 状态机与真实 YOLO 坐标联调 | ❌ | 当前参考点来自姿态，不是 YOLO 杠铃中心 |

## 8. 目录结构（6）

| 文档要求 | 状态 | 说明 |
| --- | --- | --- |
| Feature-First（exercise_catalog / vbt_tracker / workout_summary） | 🟡 | 采用 `features/today|library|live|report|records|settings|workout|shell`，职责等价但命名不同；ML Kit 适配器在 `domain/vbt/vision_pose_source*.dart` |

## 9. 里程碑（7）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| Phase 1 数据基座 + 动作百科 | ✅ | 1,324 动作/10 语言/详情/容量 |
| Phase 2 双通道 + 状态机 | 🟡 | 姿态通道真实接入；杠铃通道/真实片径缺失；状态机完成 |
| Phase 3 HUD + 报告 | 🟡 | 骨架/轨迹/报告完成；波形卡/轨迹矩阵/1RM 缺失 |
| Phase 4 视频导出 + 性能压测 | ❌ | 未实现 |

## 10. 目标平台与合规

| 要求 | 状态 | 说明 |
| --- | --- | --- |
| Android API 26+ | ✅ | minSdk 26、target/compile 36 |
| iOS 14+ | ❌ | 未构建；ML Kit Pose 要求 iOS **15.5**，与文档 14+ 冲突；项目目标已提高到 15.5 |
| 隐私/相机权限 | ✅ | Android CAMERA、iOS NSCameraUsageDescription 已声明 |
| 动作媒体版权合规 | ✅ | 不打包 Gym Visual 媒体；图谱署名 Ryan Graves / CC BY 4.0 |
| ML Kit 离线可用性 | ✅ | 姿态模型（`assets/mlkit_pose/*.tflite`）已随 APK 打包，推理无需联网；旧 GMS 机型的加速基准子进程可能崩溃，主推理继续 |

## 11. 本轮视觉推理实现边界与真机结果

已实现：

- `google_mlkit_pose_detection 0.16.1`，Android/iOS 原生推理，Web 条件编译回退 `SimulatedPoseSource`。
- 相机 `startImageStream` → NV21/YUV420 转换 → ML Kit 33 点 → 选择更可信的一侧 → `PoseFrame`。
- **坐标单位修正**：Android ML Kit 插件返回像素坐标（原始值约 0~720），适配器按旋转后的 480×720 图像归一化，再执行前置镜像；已用全身真机验证骨架不再塌缩到 `(0,1)`。
- 参考点：深蹲取肩中点，卧推/推举/硬拉/弯举取手腕中点，引体取髋中点，俯卧撑取肩中点。
- 真实姿态驱动骨架、髋/膝/肘角、状态机、计数；无完整肩/髋/膝/踝时暂停状态机，避免空坐标误计次。
- 身高标定在标定页直接启动相机 + ML Kit，实时读取鼻-踝像素高度；全身入镜后才允许确认，不再使用固定 675px 假设。
- HUD 标识 `ML KIT`，等待人体入镜提示，失败回退演示并提示。

真机验证（SM-G9650 / Android 10 / API 29）：

- 相机预览与 ML Kit 原生推理成功启动，日志返回 `[vision] pose conf=1.00`；
- HUD 顶栏可切换前置/后置摄像头；前置摄像头预览与 `[vision] stream started CameraLensDirection.front` 已验证；
- 标定页已切换为实时相机预览，并启动 ML Kit 身高测量；竖放标定已支持：真机竖放读数约 `83.1°`，状态显示「机位竖放，透视畸变很小」；水平/竖放均被接受；
- 无人/无片径时，标定页主按钮变为「使用默认标定」，可带 45 cm 默认比例尺返回，不再出现无法点击确认的死循环；
- 测试机位只捕获到部分身体，状态提示“请后退至全身入镜”，未生成真实身高比例尺；
- 全身复测：前置摄像头、全身入镜时，骨架已出现在真实人体上，左右两侧均绘制；原始像素坐标归一化后，脚踝/膝/髋/肩不再塌缩到同一点。
- 初次安装发现 `GeneratedPluginRegistrant` 缺少 ML Kit，已重新生成并注册 `google_mlkit_commons` 与 `google_mlkit_pose_detection`；
- 测试场景只捕获到部分身体，未得到完整全身骨架，因此“真实骨架逐关节对齐”仍需在全身入镜场景复测；
- ML Kit 加速基准子进程在 Android 10/GMS 版本不匹配时出现 `NoSuchFieldError` 崩溃日志，主推理进程仍继续，需机型兼容性跟进。

明确未实现：

- 杠铃端面检测（YOLOv8n/ByteTrack），因此速度是**参考点近似值**，不是严格杠铃中心速度。
- 真实杠铃片自动标定；片径模式目前是演示数据。
- 原生 C++/FFI 零拷贝、独立 Isolate、前后摄切换、机位侧向校验、视频导出、1RM/LVP。
- iOS 编译验证。

## 12. 建议优先级

1. **P0 数据正确性**：杠铃检测 + 真实片径标定；否则 VBT 速度/VL 只能作为相对趋势，不能作为负荷决策依据。
2. **P0 Tier 对齐**：按文档重分为 45/250/1,029，并实现 Tier 2 隐藏物理速度、显示 Tempo/角度波形。
3. **P1 HUD 规格**：补速度波形卡、双角度波形卡、6 列轨迹矩阵、回架检测。
4. **P1 报告**：1RM/LVP、疲劳建议、HUD 视频导出。
5. **P2 架构/平台**：原生零拷贝 + Isolate、前后摄/机位自检、iOS 15.5 构建与 Apple Vision 备选。
6. **P2 数据模型**：`ExerciseCvConfigs`、轨迹/波形 JSON、视频路径、UUID。
