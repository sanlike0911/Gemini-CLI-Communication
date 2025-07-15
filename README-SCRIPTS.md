# 🚀 AIエージェント起動スクリプト使い分けガイド

## 📋 利用可能なスクリプト

| スクリプト名 | 用途 | 起動対象 |
|-------------|------|----------|
| `./launch-president.sh` | PRESIDENT単独起動 | プロジェクト統括責任者のみ |
| `./launch-team.sh` | チーム起動 | boss1 + worker1-3 |
| `./launch-agents.sh` | 全員一括起動 | PRESIDENT + boss1 + worker1-3 |

## 🎯 使い分けのガイドライン

### 1. 段階的起動パターン（推奨）

```bash
# Step 1: PRESIDENT単独起動
./launch-president.sh

# Step 2: PRESIDENTにプロジェクト指示
./agent-send.sh president "あなたはPRESIDENTです。カフェのホームページを作成してください..."

# Step 3: チーム起動（必要に応じて）
./launch-team.sh

# Step 4: チームメンバーに役割通知
./agent-send.sh boss1 "あなたはboss1です。instructions/boss.mdに従って行動してください。"
./agent-send.sh worker1 "あなたはworker1です。instructions/worker.mdに従って行動してください。"
# worker2, worker3も同様...
```

### 2. 全員一括起動パターン

```bash
# 全員同時起動（従来通り）
./launch-agents.sh

# 各メンバーに役割通知
./agent-send.sh president "あなたはPRESIDENTです。instructions/president.mdに従って行動してください。"
./agent-send.sh boss1 "あなたはboss1です。instructions/boss.mdに従って行動してください。"
# 以下同様...
```

### 3. トラブル時の個別復旧パターン

```bash
# PRESIDENTのみ再起動
./launch-president.sh

# チームのみ再起動
./launch-team.sh
```

## 🖥️ 画面レイアウト

### PRESIDENT画面
```
tmux attach-session -t president
```
- 単一画面でPRESIDENTのみ

### チーム画面
```
tmux attach-session -t multiagent
```
```
┌─────────────┬─────────────┐
│    boss1    │   worker1   │
├─────────────┼─────────────┤
│   worker3   │   worker2   │
└─────────────┴─────────────┘
```

## 💡 各スクリプトの特徴

### `launch-president.sh`
- ✅ PRESIDENT専用の詳細な使用方法ガイド
- ✅ 単一セッション管理で軽量
- ✅ プロジェクト開始時の初期指示に最適

### `launch-team.sh`
- ✅ 4分割レイアウトで全員の作業を同時監視
- ✅ チーム連携の可視化
- ✅ ペイン間の切り替えが容易

### `launch-agents.sh`
- ✅ 従来通りの一括起動
- ✅ 設定済みの既存ワークフローと互換性維持
- ✅ シンプルな運用

## 🎯 推奨ワークフロー

### 新規プロジェクト開始時

1. **PRESIDENT起動 & 要件定義**
   ```bash
   ./launch-president.sh
   ./agent-send.sh president "新しいプロジェクト開始..."
   ```

2. **PRESIDENTがチーム必要性を判断**
   - 簡単なタスク → PRESIDENT単独で完了
   - 複雑なタスク → チーム起動を推奨

3. **チーム起動（必要に応じて）**
   ```bash
   ./launch-team.sh
   # 各メンバーに役割通知...
   ```

### 継続プロジェクト時

```bash
# 既存セッションがあれば復旧、なければ新規作成
./launch-agents.sh
```

## 🛠️ トラブルシューティング

### セッション競合時
```bash
# 既存セッションを確認
tmux list-sessions

# 強制削除して再作成
tmux kill-session -t president
tmux kill-session -t multiagent
./launch-agents.sh
```

### 個別メンバーの復旧
```bash
# 特定のペインのみ再起動
tmux send-keys -t multiagent:boss1.0 'gemini -y' C-m  # boss1
tmux send-keys -t multiagent:boss1.1 'gemini -y' C-m  # worker1
tmux send-keys -t multiagent:boss1.2 'gemini -y' C-m  # worker2
tmux send-keys -t multiagent:boss1.3 'gemini -y' C-m  # worker3
```

## 📊 パフォーマンス比較

| 起動方式 | メモリ使用量 | 起動時間 | 監視しやすさ | 使いやすさ |
|---------|-------------|----------|-------------|-----------|
| PRESIDENT単独 | 最小 | 最速 | ★★★ | ★★★★★ |
| チーム4分割 | 中程度 | 普通 | ★★★★★ | ★★★★ |
| 全員一括 | 最大 | 最遅 | ★★★ | ★★★ |

## 🎯 まとめ

- **小規模・個人プロジェクト**: `./launch-president.sh`
- **チーム協働プロジェクト**: `./launch-team.sh`
- **フルスケールプロジェクト**: `./launch-agents.sh`

各プロジェクトの規模と要件に応じて最適なスクリプトをお選びください。