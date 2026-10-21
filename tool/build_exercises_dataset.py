"""Build the prebuilt, offline exercise database used by ForceTrace.

Source: https://github.com/hasaneyldrm/exercises-dataset (data/exercises.json)

Usage:
    python tool/build_exercises_dataset.py --source /path/to/exercises.json
    # writes assets/db/initial_exercises.db.gz (10 instruction languages, 1324 rows)

The app decompresses this database on first launch (native: copy to documents;
web: initialize drift's WASM-backed IndexedDB) and then opens it with Drift.
"""
import argparse
import collections
import gzip
import json
import os
import re
import sqlite3
import sys
import tempfile

sys.stdout.reconfigure(encoding="utf-8")

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

parser = argparse.ArgumentParser()
parser.add_argument("--source", required=True, help="Path to exercises.json")
parser.add_argument(
    "--out",
    default=os.path.join(REPO_ROOT, "assets", "db"),
    help="Output directory",
)
args = parser.parse_args()

SRC = args.source
OUT_DIR = args.out
os.makedirs(OUT_DIR, exist_ok=True)

LANGS = ["en", "zh", "tr", "es", "ru", "hi", "pl", "ko", "fr", "it"]

# Longest-first phrase dictionary used to build readable Chinese exercise names.
PHRASES = {
    "barbell clean-grip front squat": "杠铃翻站握前蹲",
    "barbell bench front squat": "杠铃卧推前蹲",
    "clean and press": "翻站推举",
    "clean and jerk": "挺举",
    "front chest squat": "前胸深蹲",
    "guillotine bench press": "断头台卧推",
    "floor calf raise": "地面提踵",
    "zercher squat": "泽奇深蹲",
    "close-grip": "窄距",
    "wide-grip": "宽距",
    "reverse-grip": "反握",
    "neutral-grip": "对握",
    "clean-grip": "翻站握",
    "one-arm": "单臂",
    "single-leg": "单腿",
    "one-leg": "单腿",
    "two-leg": "双腿",
    "bent-over": "俯身",
    "side bend": "侧屈",
    "heel touchers": "触踵",
    "air bike": "空中自行车",
    "all fours": "四点跪姿",
    "back pov": "背视",
    "side pov": "侧视",
    "zercher": "泽奇",
    "guillotine": "断头台",
    "floor": "地面",
    "chest": "胸",
    "shoulders": "肩部",
    "shoulder": "肩",
    "and": "与",
    "grip": "握",
    "pov": "视角",
    "barbell bench squat": "杠铃卧推深蹲",
    "barbell full squat": "杠铃全深蹲",
    "barbell high bar squat": "杠铃高杠深蹲",
    "barbell low bar squat": "杠铃低杠深蹲",
    "barbell front squat": "杠铃前蹲",
    "barbell back squat": "杠铃后蹲",
    "barbell overhead squat": "杠铃过头深蹲",
    "barbell hack squat": "杠铃哈克深蹲",
    "barbell jump squat": "杠铃跳跃深蹲",
    "barbell speed squat": "杠铃速度深蹲",
    "barbell split squat": "杠铃分腿蹲",
    "barbell bulgarian split squat": "杠铃保加利亚分腿蹲",
    "barbell romanian deadlift": "杠铃罗马尼亚硬拉",
    "barbell stiff leg deadlift": "杠铃直腿硬拉",
    "barbell straight leg deadlift": "杠铃直腿硬拉",
    "barbell sumo deadlift": "杠铃相扑硬拉",
    "barbell single leg deadlift": "杠铃单腿硬拉",
    "barbell deadlift": "杠铃硬拉",
    "barbell incline bench press": "杠铃上斜卧推",
    "barbell decline bench press": "杠铃下斜卧推",
    "barbell close-grip bench press": "杠铃窄距卧推",
    "barbell wide bench press": "杠铃宽距卧推",
    "barbell bench press": "杠铃卧推",
    "barbell seated overhead press": "杠铃坐姿推举",
    "barbell overhead press": "杠铃推举",
    "barbell military press": "杠铃军事推举",
    "barbell bent over row": "杠铃俯身划船",
    "barbell row": "杠铃划船",
    "barbell hip thrust": "杠铃臀推",
    "barbell good morning": "杠铃早安式",
    "barbell calf raise": "杠铃提踵",
    "barbell curl": "杠铃弯举",
    "barbell shrug": "杠铃耸肩",
    "barbell clean": "杠铃翻站",
    "barbell snatch": "杠铃抓举",
    "barbell thruster": "杠铃推举深蹲",
    "barbell lunge": "杠铃弓步",
    "barbell glute bridge": "杠铃臀桥",
    "barbell upright row": "杠铃直立划船",
    "barbell bench": "杠铃卧推",
    "dumbbell bench press": "哑铃卧推",
    "dumbbell incline bench press": "哑铃上斜卧推",
    "dumbbell romanian deadlift": "哑铃罗马尼亚硬拉",
    "dumbbell biceps curl": "哑铃二头弯举",
    "dumbbell concentration curl": "哑铃集中弯举",
    "dumbbell hammer curl": "哑铃锤式弯举",
    "dumbbell lateral raise": "哑铃侧平举",
    "dumbbell front raise": "哑铃前平举",
    "dumbbell shoulder press": "哑铃肩推",
    "dumbbell fly": "哑铃飞鸟",
    "dumbbell pullover": "哑铃仰卧上拉",
    "dumbbell row": "哑铃划船",
    "dumbbell lunge": "哑铃弓步",
    "dumbbell squat": "哑铃深蹲",
    "dumbbell walking lunge": "哑铃行走弓步",
    "bulgarian split squat": "保加利亚分腿蹲",
    "split squat": "分腿蹲",
    "front squat": "前蹲",
    "back squat": "后蹲",
    "goblet squat": "高脚杯深蹲",
    "hack squat": "哈克深蹲",
    "jump squat": "跳跃深蹲",
    "sumo squat": "相扑深蹲",
    "squat": "深蹲",
    "romanian deadlift": "罗马尼亚硬拉",
    "stiff leg deadlift": "直腿硬拉",
    "straight leg deadlift": "直腿硬拉",
    "sumo deadlift": "相扑硬拉",
    "deadlift": "硬拉",
    "bench press": "卧推",
    "overhead press": "推举",
    "military press": "军事推举",
    "shoulder press": "肩推",
    "incline press": "上斜推胸",
    "decline press": "下斜推胸",
    "chest press": "推胸",
    "leg press": "腿举",
    "hip thrust": "臀推",
    "glute bridge": "臀桥",
    "good morning": "早安式",
    "calf raise": "提踵",
    "biceps curl": "二头弯举",
    "triceps extension": "三头伸展",
    "leg extension": "腿屈伸",
    "leg curl": "腿弯举",
    "wrist curl": "腕弯举",
    "hammer curl": "锤式弯举",
    "concentration curl": "集中弯举",
    "preacher curl": "牧师凳弯举",
    "curl": "弯举",
    "pushdown": "下压",
    "pulldown": "下拉",
    "pull-up": "引体向上",
    "pull up": "引体向上",
    "chin-up": "反手引体向上",
    "chin up": "反手引体向上",
    "push-up": "俯卧撑",
    "push up": "俯卧撑",
    "sit-up": "仰卧起坐",
    "sit up": "仰卧起坐",
    "dip": "臂屈伸",
    "lunge": "弓步",
    "row": "划船",
    "fly": "飞鸟",
    "raise": "上举",
    "shrug": "耸肩",
    "crunch": "卷腹",
    "plank": "平板支撑",
    "twist": "扭转",
    "rotation": "旋转",
    "extension": "伸展",
    "flexion": "屈曲",
    "kickback": "后踢",
    "pullover": "上拉",
    "thruster": "推举深蹲",
    "clean": "翻站",
    "snatch": "抓举",
    "jerk": "挺举",
    "press": "推",
    "squat": "深蹲",
    "deadlift": "硬拉",
    "lunge": "弓步",
    "step": "台阶",
    "walk": "行走",
    "run": "跑步",
    "jump": "跳跃",
    "swing": "摆动",
    "carry": "搬运",
    "hold": "保持",
    "stretch": "拉伸",
    "barbell": "杠铃",
    "dumbbell": "哑铃",
    "kettlebell": "壶铃",
    "cable": "绳索",
    "smith machine": "史密斯机",
    "leverage machine": "固定器械",
    "body weight": "自重",
    "ez barbell": "EZ 杠铃",
    "olympic barbell": "奥林匹克杠铃",
    "trap bar": "六角杠铃",
    "resistance band": "弹力带",
    "band": "弹力带",
    "stability ball": "瑞士球",
    "bosu ball": "波速球",
    "medicine ball": "药球",
    "assisted": "辅助",
    "weighted": "负重",
    "sled machine": "雪橇机",
    "hammer": "锤",
    "wheel roller": "健腹轮",
    "roller": "滚轮",
    "rope": "绳索",
    "tire": "轮胎",
    "upper body ergometer": "上肢功率车",
    "skierg machine": "滑雪机",
    "stationary bike": "动感单车",
    "elliptical machine": "椭圆机",
    "stepmill machine": "台阶机",
    "one arm": "单臂",
    "single leg": "单腿",
    "one leg": "单腿",
    "two leg": "双腿",
    "alternate": "交替",
    "reverse": "反向",
    "seated": "坐姿",
    "standing": "站姿",
    "lying": "仰卧",
    "kneeling": "跪姿",
    "incline": "上斜",
    "decline": "下斜",
    "close grip": "窄距",
    "wide grip": "宽距",
    "bent over": "俯身",
    "side": "侧",
    "front": "前",
    "back": "后",
    "high": "高",
    "low": "低",
    "full": "全",
    "half": "半",
    "v. 2": "V2",
    "v. 1": "V1",
}

# Exact overrides for the flagship movements.
OVERRIDES = {
    "barbell full squat": "杠铃深蹲",
    "barbell full squat (side pov)": "杠铃深蹲（侧视）",
    "barbell squat (on knees)": "杠铃深蹲（跪姿）",
    "barbell bench press": "杠铃卧推",
    "barbell deadlift": "杠铃硬拉",
    "barbell romanian deadlift": "杠铃罗马尼亚硬拉",
    "barbell incline bench press": "上斜杠铃卧推",
    "barbell seated overhead press": "杠铃坐姿推举",
    "barbell bent over row": "杠铃俯身划船",
    "pull-up": "引体向上",
    "push-up": "俯卧撑",
    "dip": "双杠臂屈伸",
    "dumbbell biceps curl": "哑铃弯举",
    "barbell bulgarian split squat": "杠铃保加利亚分腿蹲",
}

def zh_name(name: str) -> str:
    key = name.lower().strip()
    if key in OVERRIDES:
        return OVERRIDES[key]
    # Remove parenthetical/slash decorations for cleaner translation, keep suffix.
    suffix = ""
    m = re.search(r"\s*\((.*?)\)\s*$", key)
    if m:
        suffix = m.group(1)
        key = key[: m.start()].strip()
    suffix = {
        "back pov": "背视",
        "side pov": "侧视",
        "on knees": "跪姿",
        "male": "男",
        "female": "女",
        "kneeling": "跪姿",
    }.get(suffix.lower(), suffix)
    phrases = sorted(PHRASES.keys(), key=len, reverse=True)
    out = key
    for p in phrases:
        out = re.sub(r"(?<![a-z])" + re.escape(p) + r"(?![a-z])", PHRASES[p], out, flags=re.I)
    out = out.replace("/", "")
    out = re.sub(r"\s+", " ", out).strip()
    if suffix:
        out += f"（{suffix}）"
    if not re.search(r"[\u4e00-\u9fff]", out):
        return name
    return out

TIER1_KEYWORDS = [
    "squat", "deadlift", "bench press", "overhead press", "military press",
    "shoulder press", "barbell row", "bent over row", "pendlay row",
    "hip thrust", "good morning", "clean", "snatch", "jerk", "thruster",
    "split squat", "lunge", "calf raise",
]
BARBELL_LIKE = {"barbell", "olympic barbell", "trap bar", "ez barbell"}
FREE_WEIGHT = {
    "body weight", "dumbbell", "kettlebell", "band", "resistance band",
    "ez barbell", "weighted", "assisted", "stability ball", "bosu ball",
    "medicine ball",
}

def tier_of(name: str, equipment: str) -> int:
    n = name.lower()
    if equipment in ("barbell", "olympic barbell", "trap bar"):
        if any(k in n for k in TIER1_KEYWORDS):
            return 1
        return 2
    if equipment in FREE_WEIGHT:
        return 2
    return 3

data = json.load(open(SRC, encoding="utf-8"))
out = []
for e in data:
    steps = {}
    for lang in LANGS:
        s = e.get("instruction_steps", {}).get(lang) or []
        if s:
            steps[lang] = s
    name = e["name"]
    out.append({
        "id": e["id"],
        "name": name,
        "zh": zh_name(name),
        "category": e.get("category") or e.get("body_part") or "other",
        "bodyPart": e.get("body_part") or "",
        "equipment": e.get("equipment") or "other",
        "target": e.get("target") or "",
        "secondary": e.get("secondary_muscles") or [],
        "tier": tier_of(name, e.get("equipment") or ""),
        "media": e.get("media_id") or "",
        "steps": steps,
    })

payload = {"version": 1, "languages": LANGS, "exercises": out}
raw = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
print("json-raw", round(len(raw) / 1024 / 1024, 2), "MB")

DB_SCHEMA = """CREATE TABLE "app_meta" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("key"));
CREATE TABLE "exercise_details" ("exercise_id" TEXT NOT NULL REFERENCES exercises (id) ON DELETE CASCADE, "steps" TEXT NOT NULL, PRIMARY KEY ("exercise_id"));
CREATE TABLE "exercises" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "local_name" TEXT NOT NULL DEFAULT '', "category" TEXT NOT NULL, "body_part" TEXT NOT NULL, "equipment" TEXT NOT NULL, "target" TEXT NOT NULL, "secondary_muscles" TEXT NOT NULL DEFAULT '[]', "tier" INTEGER NOT NULL, "media_id" TEXT NOT NULL DEFAULT '', PRIMARY KEY ("id"));
CREATE TABLE "plan_items" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "exercise_id" TEXT NOT NULL, "day" TEXT NOT NULL, "position" INTEGER NOT NULL DEFAULT 0, "target_sets" INTEGER NOT NULL DEFAULT 3, "target_reps" INTEGER NOT NULL DEFAULT 8, "weight_kg" REAL NOT NULL DEFAULT 0.0, "completed_sets" INTEGER NOT NULL DEFAULT 0, UNIQUE ("exercise_id", "day"));
CREATE TABLE "rep_records" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "session_id" INTEGER NOT NULL REFERENCES workout_sessions (id) ON DELETE CASCADE, "rep_index" INTEGER NOT NULL, "mean_velocity" REAL NOT NULL, "peak_velocity" REAL NOT NULL, "rom_cm" REAL NOT NULL, "velocity_loss_percent" REAL NOT NULL, "duration_ms" INTEGER NOT NULL, "eccentric_ms" INTEGER NOT NULL, "concentric_ms" INTEGER NOT NULL, "min_hip_angle" REAL NOT NULL, "min_knee_angle" REAL NOT NULL, "is_best_rep" INTEGER NOT NULL DEFAULT 0 CHECK ("is_best_rep" IN (0, 1)));
CREATE TABLE "set_logs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "exercise_id" TEXT NOT NULL, "exercise_name" TEXT NOT NULL, "tier" INTEGER NOT NULL, "performed_at" INTEGER NOT NULL, "weight_kg" REAL NOT NULL DEFAULT 0.0, "reps" INTEGER NOT NULL, "rpe" REAL NOT NULL DEFAULT 0.0, "rest_seconds" INTEGER NOT NULL DEFAULT 0, "notes" TEXT NOT NULL DEFAULT '');
CREATE TABLE "workout_sessions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "exercise_id" TEXT NOT NULL DEFAULT '', "exercise_name" TEXT NOT NULL, "tier" INTEGER NOT NULL, "started_at" INTEGER NOT NULL, "finished_at" INTEGER NOT NULL, "weight_kg" REAL NOT NULL DEFAULT 0.0, "plate_diameter_cm" REAL NOT NULL DEFAULT 45.0, "scale_meters_per_pixel" REAL NOT NULL, "total_reps" INTEGER NOT NULL, "invalid_reps" INTEGER NOT NULL DEFAULT 0, "avg_mean_velocity" REAL NOT NULL, "best_mean_velocity" REAL NOT NULL, "peak_velocity" REAL NOT NULL, "best_rom_cm" REAL NOT NULL, "velocity_loss" REAL NOT NULL, "notes" TEXT NOT NULL DEFAULT '');
"""

out_dir = OUT_DIR
os.makedirs(out_dir, exist_ok=True)
db_path = os.path.join(tempfile.gettempdir(), "force_trace_initial.db")
if os.path.exists(db_path):
    os.remove(db_path)

conn = sqlite3.connect(db_path)
conn.executescript(DB_SCHEMA)
conn.executemany(
    """INSERT INTO exercises
       (id, name, local_name, category, body_part, equipment, target,
        secondary_muscles, tier, media_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
    [
        (
            e["id"],
            e["name"],
            e["zh"],
            e["category"],
            e["bodyPart"],
            e["equipment"],
            e["target"],
            json.dumps(e["secondary"], ensure_ascii=False, separators=(",", ":")),
            e["tier"],
            e["media"],
        )
        for e in out
    ],
)
conn.executemany(
    "INSERT INTO exercise_details (exercise_id, steps) VALUES (?, ?)",
    [
        (
            e["id"],
            json.dumps(e["steps"], ensure_ascii=False, separators=(",", ":")),
        )
        for e in out
    ],
)
conn.execute("INSERT INTO app_meta (key, value) VALUES ('seed_version', '1')")
conn.execute("PRAGMA user_version = 1")
conn.commit()
conn.execute("VACUUM")
conn.close()

db_bytes = open(db_path, "rb").read()
gz = gzip.compress(db_bytes, compresslevel=9, mtime=0)
gz_path = os.path.join(out_dir, "initial_exercises.db.gz")
open(gz_path, "wb").write(gz)

print("exercises", len(out))
print("db", round(len(db_bytes) / 1024 / 1024, 2), "MB")
print("db.gz", round(len(gz) / 1024 / 1024, 2), "MB")
print("wrote", gz_path)
print("tiers", collections.Counter(x["tier"] for x in out))
print("equipment tiers", collections.Counter((x["equipment"], x["tier"]) for x in out).most_common(15))
for i in range(1, 4):
    print("TIER", i, [x["name"] for x in out if x["tier"] == i][:12])
for name in [
    "barbell full squat",
    "barbell bench press",
    "barbell deadlift",
    "barbell romanian deadlift",
    "barbell incline bench press",
    "barbell seated overhead press",
    "barbell bent over row",
    "pull-up",
    "push-up",
    "dip",
    "dumbbell biceps curl",
    "barbell bulgarian split squat",
]:
    ex = next((x for x in out if x["name"] == name), None)
    print(name, "=>", ex["zh"] if ex else "MISSING", "tier", ex["tier"] if ex else "-")

