# 📋 Gemini CLI エージェント通信システム 使用方法

## 🚀 クイックスタート

### 1. 環境準備
```bash
# 1. プロジェクトをダウンロード
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication

# 2. tmuxセッションを作成
./setup.sh
```

### 2. エージェント起動

#### 👑 社長（PRESIDENT）起動
```bash
./launch-president.sh
```
- 自動的に`gemini-2.5-flash`モデルで起動
- PRESIDENT専用画面が表示される
- 認証が必要な場合は画面の指示に従う

#### 🎯 チーム（boss1 + worker1-3）起動
別ターミナルで実行：
```bash
./launch-team.sh
```
- 4分割画面が表示される
- 全員が`gemini-2.5-flash`モデルで起動
- 自動承認モード（-y）で動作

### 3. 基本的な使い方

#### エージェントに役割を教える
各画面で最初に実行：

**PRESIDENT画面で：**
```
あなたはPRESIDENTです。instructions/president.mdに従って行動してください。
```

**boss1画面で：**
```
あなたはboss1です。instructions/boss.mdに従って行動してください。
```

**worker1-3画面で：**
```
あなたはworker1です。instructions/worker.mdに従って行動してください。
（worker2, worker3も同様）
```

#### プロジェクト開始
PRESIDENT画面で：
```
カフェのホームページを作成してください。モダンなデザインで、React + TypeScript + Tailwind CSSを使用。
```

## 🖥️ 画面操作

### tmux基本操作
```bash
# セッション一覧表示
tmux ls

# セッションに接続
tmux attach-session -t president    # 社長画面
tmux attach-session -t multiagent   # チーム画面

# セッションから切り離し（Ctrl+b → d）
# ※ エージェントは動き続ける
```

### 4分割画面の操作
```bash
# ペイン間の移動（tmux画面内で）
Ctrl+b → 矢印キー

# ペイン構成
┌────────┬────────┐
│ boss1  │worker1 │  ← 左上：boss1、右上：worker1
├────────┼────────┤
│worker3 │worker2 │  ← 左下：worker3、右下：worker2
└────────┴────────┘
```

## 💬 メッセージ送信

### agent-send.shの使用
```bash
# 基本形式
./agent-send.sh [相手] "[メッセージ]"

# 例：boss1に指示
./agent-send.sh boss1 "新しいタスクです。UIコンポーネントを3つ作成してください。"

# 例：worker1に質問
./agent-send.sh worker1 "進捗はいかがですか？"

# 例：全員に一斉送信
for agent in boss1 worker1 worker2 worker3; do
  ./agent-send.sh $agent "定例ミーティングを開始します"
done
```

### メッセージの対象
- `president` - 社長
- `boss1` - チームリーダー
- `worker1` - 作業者1（通常：フロントエンド）
- `worker2` - 作業者2（通常：バックエンド）
- `worker3` - 作業者3（通常：インフラ/テスト）

## ⚙️ 設定ファイル

### gemini-config.json
```json
{
  "model": "gemini-2.5-flash",
  "yolo_mode": true,
  "debug": false,
  "sandbox": false,
  "all_files": false,
  "show_memory_usage": false,
  "telemetry": false
}
```

**設定項目：**
- `model`: 使用するGeminiモデル
- `yolo_mode`: 自動承認モード（trueで確認なし）
- `debug`: デバッグモード
- `all_files`: 全ファイルをコンテキストに含める

### モデル変更
```bash
# config編集
nano gemini-config.json

# 例：モデルを変更
{
  "model": "gemini-2.0-flash-exp"
}
```

## 🔄 ワークフロー例

### Webアプリ開発の場合

1. **PRESIDENT**: 要件定義
```
あなたはpresidentです。
ECサイトを作成してください。商品一覧、カート機能、決済機能を含む。
```

2. **boss1**: タスク分解・指示
```
あなたはboss1です。
以下のタスクを分担してください：
- worker1: フロントエンド（React）
- worker2: バックエンド（Node.js + Express）
- worker3: データベース設計とテスト
```

3. **worker1-3**: 並行作業
各自が専門分野の実装を進行

4. **boss1**: 統合・品質管理
完成したコンポーネントを統合

5. **PRESIDENT**: 最終確認・承認

## 🛠️ トラブルシューティング

### エージェントが起動しない
```bash
# tmux状態確認
tmux ls

# セッションが存在しない場合
./setup.sh

# Gemini CLI認証エラーの場合
# 各画面で手動認証を実行
```

### 応答が遅い・止まった
```bash
# 現在の状態確認
tmux attach-session -t multiagent

# 特定のエージェントを再起動
tmux send-keys -t multiagent:0.1 C-c    # worker1を停止
tmux send-keys -t multiagent:0.1 "gemini -m 'gemini-2.5-flash' -y" C-m  # 再起動
```

### メッセージが届かない
```bash
# ログ確認
cat logs/send_log.txt

# 手動テスト
./agent-send.sh boss1 "テストメッセージ"

# エージェント状態確認
tmux capture-pane -t multiagent:0.0 -p  # boss1の画面内容を確認
```

### 全体リセット
```bash
# 全セッション削除
tmux kill-server

# 一時ファイル削除
rm -rf ./tmp/*

# 再構築
./setup.sh
./launch-president.sh
./launch-team.sh
```

## 📊 進捗管理

### 完了マーカーファイル
```bash
# 作業完了時に自動作成される
./tmp/worker1_done.txt
./tmp/worker2_done.txt  
./tmp/worker3_done.txt

# 進捗確認
ls -la ./tmp/worker*_done.txt
```

### ログファイル
```bash
# メッセージ送信ログ
tail -f logs/send_log.txt

# 進捗ログ
tail -f logs/progress.log
```

## 💡 効果的な使い方のコツ

### 1. 明確な指示
❌ 悪い例：
```
何か作って
```

✅ 良い例：
```
あなたはpresidentです。

【プロジェクト】カフェの予約システム
【機能】
- 席の予約・キャンセル
- 空席状況の確認
- 顧客情報管理

【技術要件】
- フロントエンド：React + TypeScript
- バックエンド：Node.js + Express
- データベース：PostgreSQL

【成功基準】
- レスポンス時間1秒以内
- 同時アクセス100人対応
- テストカバレッジ80%以上
```

### 2. 定期的な進捗確認
```bash
# 30分ごとに状況確認
./agent-send.sh boss1 "現在の進捗状況を報告してください"
```

### 3. 役割の明確化
各エージェントの専門分野を活かす：
- **worker1**: UI/UX、フロントエンド
- **worker2**: API、データ処理
- **worker3**: インフラ、テスト、デプロイ

## 🎯 実践例：TODOアプリ開発

### ステップ1：プロジェクト開始
PRESIDENT画面で：
```
あなたはpresidentです。
シンプルなTODOアプリを作成してください。
- タスクの追加・削除・完了機能
- 優先度設定
- 期限管理
- ローカルストレージ保存
- レスポンシブデザイン
```

### ステップ2：自動的な作業分担
boss1が自動的に作業を分担：
- worker1: フロントエンド実装
- worker2: データ管理ロジック
- worker3: テスト・デプロイ準備

### ステップ3：完成確認
約1-2時間で完成したアプリを確認

この流れで、効率的にプロジェクトを進められます。