# 🤖 Gemini CLI エージェント通信システム

複数のAIが協力して働く、まるで会社のような開発システムです（Gemini CLI版）

## 移植バージョン

フォーク元のプロジェクトで「Claude Code CLI」を使用していたAI組織システムを、「Gemini CLI」に移植したバージョンです。

## 📌 これは何？

**3行で説明すると：**

1. 複数のAIエージェント（社長・マネージャー・作業者）が協力して開発
2. それぞれ異なるターミナル画面で動作し、メッセージを送り合う
3. 人間の組織のように役割分担して、効率的に開発を進める

**実際の成果：**

- 3時間で完成したアンケートシステム（EmotiFlow）
- 12個の革新的アイデアを生成
- 100%のテストカバレッジ

## 🚀 クイックスタート

### 必要なもの

- Mac または Linux
- tmux（ターミナル分割ツール）
- Gemini CLI

### エージェント構成

- **PRESIDENT** (singleagent): 統括責任者 - Gemini CLIで動作
- **boss1** (multiagent:0.0): チームリーダー - Gemini CLIで動作
- **worker1,2,3** (multiagent:0.1-3): 実行担当 - Gemini CLIで動作

### 基本フロー

PRESIDENT → boss1 → workers → boss1 → PRESIDENT

### Gemini CLI 特有の注意事項

- 認証は各セッションで個別に必要
- レスポンス形式はClaude Codeとは異なる場合がある
- ツール利用可能性を確認して使用

### 基本的な起動手順

#### 1️⃣ ダウンロード（30秒）

```bash
git clone https://github.com/sanlike0911/Gemini-CLI-Communication.git
cd Gemini-CLI-Communication
```

#### 2️⃣ システム起動

```bash
# 統合セットアップ（プロジェクト選択→環境構築）
./setup.sh
```

#### 3️⃣ 個別起動

1. 社長用ウインドウを立ち上げ、以下を実行

   ```bash
   # 個別エージェント起動
   ./launch-president.sh  # 社長起動
   ```

2. 「2️⃣システム起動」を行ったウインドウで以下を実行

   ```bash
   # 個別エージェント起動
   ./launch-team.sh       # チーム起動
   ```

#### 4️⃣ 魔法の言葉を入力

社長画面で入力：

```md
あなたはpresidentです。おしゃれな充実したIT企業のホームページを作成して。
```

**すると自動的に：**

1. 社長がマネージャーに指示
2. マネージャーが3人の作業者に仕事を割り振り
3. みんなで協力して開発
4. 完成したら社長に報告

#### 5️⃣ 組織の動作フロー

```md
PRESIDENT → boss1 → worker1,2,3 → boss1 → PRESIDENT
```

**具体的な流れ：**
1. **PRESIDENT**が`./agent-send.sh boss1 "指示内容"`でboss1に指示
2. **boss1**が各workerに専門分野を割り当て
   - `./agent-send.sh worker1 "フロントエンド担当"`
   - `./agent-send.sh worker2 "バックエンド担当"`
   - `./agent-send.sh worker3 "インフラ・テスト担当"`
3. **各worker**が`./agent-send.sh boss1 "完了報告"`でboss1に報告
4. **boss1**が`./agent-send.sh president "統合報告"`でPRESIDENTに報告

## 🗂️ プロジェクト管理システム

### 概要
プロジェクトごとに異なる指示書と設定を管理できるシステムです。複数のプロジェクトを切り替えながら、それぞれに最適化されたAIエージェントチームで開発を進められます。

### プロジェクト構造
```
./projects/
├── programming-organization/
│   ├── instructions/          # プロジェクト固有の指示書
│   │   ├── president.md       # PRESIDENT専用指示書
│   │   ├── boss.md            # boss1専用指示書
│   │   └── worker.md          # worker1-3共通指示書
│   └── workspace/             # 作業ディレクトリ
└── (他のプロジェクト...)

# 現在のディレクトリ（シンボリックリンク）
./instructions -> ./projects/[現在のプロジェクト]/instructions/
./workspace -> ./projects/[現在のプロジェクト]/workspace/
```

### プロジェクト管理コマンド
```bash
# 対話式プロジェクト選択
./project-manager.sh

# プロジェクト一覧表示
./project-manager.sh list

# プロジェクト直接選択
./project-manager.sh select programming-organization

# 現在のプロジェクト表示
./project-manager.sh current

# 指示書編集
./project-manager.sh edit
```

### 統合起動スクリプト
```bash
# 対話式起動（推奨）
./setup.sh

# プロジェクト指定起動
./setup.sh --project programming-organization
```

## 🏢 登場人物（エージェント）

### 👑 社長（PRESIDENT）
- **役割**: 全体の方針を決める
- **特徴**: ユーザーの本当のニーズを理解する天才
- **口癖**: 「このビジョンを実現してください」

### 🎯 マネージャー（boss1）
- **役割**: チームをまとめる中間管理職
- **特徴**: メンバーの創造性を引き出す達人
- **口癖**: 「革新的なアイデアを3つ以上お願いします」

### 👷 作業者たち（worker1, 2, 3）
- **worker1**: フロントエンド担当（UI/UX、React等）
- **worker2**: バックエンド担当（API、データベース等）
- **worker3**: インフラ・テスト担当（デプロイ、テスト等）

## 🖥️ 画面操作とスクリプト使い分け

### 利用可能なスクリプト

| スクリプト名 | 用途 | 起動対象 |
|-------------|------|----------|
| `./setup.sh` | 統合セットアップ | プロジェクト選択→環境構築→エージェント起動 |
| `./launch-president.sh` | PRESIDENT単独起動 | プロジェクト統括責任者のみ |
| `./launch-team.sh` | チーム起動 | boss1 + worker1-3 |

### 画面構成
**PRESIDENT画面**
```bash
tmux attach-session -t singleagent
```

**チーム画面（4分割）**
```bash
tmux attach-session -t multiagent
```
```
┌────────┬────────┐
│ boss1  │worker1 │  ← 左上：boss1、右上：worker1
├────────┼────────┤
│worker3 │worker2 │  ← 左下：worker3、右下：worker2
└────────┴────────┘
```

### tmux基本操作
```bash
# セッション一覧表示
tmux ls

# セッションに接続
tmux attach-session -t singleagent  # 社長画面
tmux attach-session -t multiagent   # チーム画面

# セッションから切り離し（Ctrl+b → d）
# ※ エージェントは動き続ける

# ペイン間の移動（tmux画面内で）
Ctrl+b → 矢印キー
```

## 💬 メッセージ送信システム

### agent-send.shの使用
```bash
# 基本形式
./agent-send.sh [相手] "[メッセージ]"

# 例：マネージャーに送る
./agent-send.sh boss1 "新しいプロジェクトです"

# 例：作業者1に送る
./agent-send.sh worker1 "UIを作ってください"

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

### 実際のやり取りの例

**社長 → マネージャー：**
```
あなたはboss1です。

【プロジェクト名】アンケートシステム開発

【ビジョン】
誰でも簡単に使えて、結果がすぐ見られるシステム

【成功基準】
- 3クリックで回答完了
- リアルタイムで結果表示

革新的なアイデアで実現してください。
```

**マネージャー → 作業者：**
```
あなたはworker1です。

【プロジェクト】アンケートシステム

【チャレンジ】
UIデザインの革新的アイデアを3つ以上提案してください。

【フォーマット】
1. アイデア名：[キャッチーな名前]
   概要：[説明]
   革新性：[何が新しいか]
```

## ⚙️ 設定ファイル

### gemini-config.json
```json
{
  "yolo_mode": true,
  "debug": false,
  "sandbox": false,
  "all_files": false,
  "show_memory_usage": false,
  "telemetry": false
}
```

**設定項目：**
- `yolo_mode`: 自動承認モード（trueで確認なし）
- `debug`: デバッグモード
- `sandbox`: サンドボックスモード
- `all_files`: 全ファイルをコンテキストに含める
- `show_memory_usage`: メモリ使用量表示
- `telemetry`: テレメトリー送信

**注意**: モデル設定は各プロジェクトのproject.jsonファイルで管理されます。

### モデル変更
プロジェクトごとのモデル変更は、project.jsonファイルを編集します：
```bash
# プロジェクト設定編集
nano ./projects/[プロジェクト名]/project.json

# 例：各エージェントのモデル変更
{
  "agents": [
    {
      "role": "president",
      "model": "gemini-2.0-flash-exp"
    }
  ]
}
```

## 📁 重要なファイルの説明

### 指示書（instructions/）
各エージェントの行動マニュアルです（プロジェクト固有）

**president.md** - 社長の指示書
```markdown
# あなたの役割
最高の経営者として、ユーザーのニーズを理解し、
ビジョンを示してください

# ニーズの5層分析
1. 表層：何を作るか
2. 機能層：何ができるか  
3. 便益層：何が改善されるか
4. 感情層：どう感じたいか
5. 価値層：なぜ重要か
```

**boss.md** - マネージャーの指示書
```markdown
# あなたの役割
天才的なファシリテーターとして、
チームの創造性を最大限に引き出してください

# 10分ルール
10分ごとに進捗を確認し、
困っているメンバーをサポートします
```

**worker.md** - 作業者の指示書
```markdown
# あなたの役割
専門性を活かして、革新的な実装をしてください

# タスク管理
1. やることリストを作る
2. 順番に実行
3. 完了したら報告
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

## 💼 プロジェクト使用例

### Webアプリ開発プロジェクト

#### 1. プロジェクト作成
```bash
mkdir -p ./projects/webapp-dashboard/{instructions,workspace}
./project-manager.sh select webapp-dashboard
```

#### 2. 指示書カスタマイズ
```bash
./project-manager.sh edit
```

**president.md の例:**
```markdown
# 👑 WebApp Dashboard - PRESIDENT指示書

## プロジェクト目標
管理者向けダッシュボードWebアプリケーションの開発

## 技術要件
- フロントエンド: React + TypeScript + Tailwind CSS
- バックエンド: Node.js + Express + PostgreSQL
- 認証: JWT
- デプロイ: Docker + AWS ECS

## 成功基準
- レスポンス時間: 2秒以内
- セキュリティ: OWASP準拠
- テストカバレッジ: 80%以上
```

#### 3. システム起動
```bash
./setup.sh
```

#### 4. プロジェクト開始
PRESIDENT画面で:
```
あなたはpresidentです。
管理者向けダッシュボードWebアプリケーションを作成してください。
ユーザー管理、データ分析、レポート機能を含む包括的なシステムです。
```

## 🛠️ トラブルシューティング

### エージェントが反応しない
```bash
# 状態を確認
tmux ls

# 各画面の状態確認
tmux attach-session -t singleagent # 社長画面
tmux attach-session -t multiagent  # チーム画面

# 再起動
./setup.sh
./launch-president.sh
./launch-team.sh
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
# ログを見る
cat logs/send_log.txt

# 手動でテスト
./agent-send.sh boss1 "テスト"

# エージェント状態確認
tmux capture-pane -t multiagent:0.0 -p  # boss1の画面内容を確認
```

### 全体リセット
```bash
# 全部リセット
tmux kill-server
rm -rf ./tmp/*
./setup.sh
```

### プロジェクト関連のトラブル

#### プロジェクトが見つからない
```bash
# プロジェクト一覧確認
./project-manager.sh list

# プロジェクトディレクトリ確認
ls -la ./projects/

# 手動作成
mkdir -p ./projects/my-project/{instructions,workspace}
```

#### シンボリックリンクの問題
```bash
# 現在のリンク確認
ls -la ./instructions ./workspace

# リンクを再作成
./project-manager.sh select [プロジェクト名]
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
- **worker1**: フロントエンド（UI/UX、React等）
- **worker2**: バックエンド（API、データベース等）
- **worker3**: インフラ・テスト（デプロイ、テスト等）

### あなたの役割（各エージェント用）
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## 🎯 推奨ワークフロー

### 新規プロジェクト開始時

1. **プロジェクト準備**
   ```bash
   mkdir -p ./projects/my-project/{instructions,workspace}
   ./project-manager.sh select my-project
   ```

2. **PRESIDENT起動 & 要件定義**
   - 簡単なタスク → PRESIDENT単独で完了
   - 複雑なタスク → チーム起動を推奨

3. **システム起動**
   ```bash
   # 統合起動（推奨）
   ./setup.sh
   ```

### 継続プロジェクト時

```bash
# プロジェクト選択→起動
./setup.sh
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

### 進捗管理の仕組み
```
./tmp/
├── worker1_done.txt     # 作業者1が完了したらできるファイル
├── worker2_done.txt     # 作業者2が完了したらできるファイル
├── worker3_done.txt     # 作業者3が完了したらできるファイル
└── worker*_progress.log # 進捗の記録
```

## 💡 なぜこれがすごいの？

### 従来の開発
```
人間 → AI → 結果
```

### このシステム
```
人間 → AI社長 → AIマネージャー → AI作業者×3 → 統合 → 結果
```

**メリット：**
- 並列処理で3倍速い
- 専門性を活かせる
- アイデアが豊富
- 品質が高い

## 📊 パフォーマンス比較

| 起動方式 | メモリ使用量 | 起動時間 | 監視しやすさ | 使いやすさ |
|---------|-------------|----------|-------------|-----------|
| PRESIDENT単独 | 最小 | 最速 | ★★★ | ★★★★★ |
| チーム4分割 | 中程度 | 普通 | ★★★★★ | ★★★★ |
| 統合起動 | 中程度 | 普通 | ★★★★ | ★★★★★ |

## 🌟 まとめ

このシステムは、複数のAIが協力することで：
- **3時間**で本格的なWebアプリが完成
- **12個**の革新的アイデアを生成
- **100%**のテストカバレッジを実現

プロジェクト管理システムにより、複数のプロジェクトを効率的に管理し、それぞれに最適化されたAIエージェントチームで開発を進めることができます。

ぜひ試してみて、AIチームの力を体験してください！

---

**作者**: [GitHub](https://github.com/sanlike0911/Gemini-CLI-Communication)
**ライセンス**: MIT
**質問**: [Issues](https://github.com/sanlike0911/Gemini-CLI-Communication/issues)へどうぞ！

## 参考リンク
    
・Gemini CLI公式   
　　URL: https://github.com/google/gemini-cli   
    
・Tmux Cheat Sheet & Quick Reference | Session, window, pane and more     
　　URL: https://tmuxcheatsheet.com/   
     
・Akira-Papa/Claude-Code-Communication（元のClaude Code版）   
　　URL: https://github.com/Akira-Papa/Claude-Code-Communication   
     
・【tmuxでClaude CodeのMaxプランでAI組織を動かし放題のローカル環境ができた〜〜〜！ので、やり方をシェア！！🔥🔥🔥🙌☺️】 #AIエージェント - Qiita   
　　URL: https://qiita.com/akira_papa_AI/items/9f6c6605e925a88b9ac5   
    
・Claude Code コマンドチートシート完全ガイド #ClaudeCode - Qiita   
　　URL: https://qiita.com/akira_papa_AI/items/d68782fbf03ffd9b2f43   
    
    
※以下の情報を参考に、今回のtmuxのGemini CLI組織環境を構築することができました。本当にありがとうございました！☺️🙌   
    
◇Claude Code双方向通信をシェルで一撃構築できるようにした発案者の元木さん   
参考GitHub ：   
haconiwa/README_JA.md at main · dai-motoki/haconiwa  
　　URL: https://github.com/dai-motoki/haconiwa/blob/main/README_JA.md   
    
・神威/KAMUI（@kamui_qai）さん / X   
　　URL: https://x.com/kamui_qai   
    
◇簡単にClaude Code双方向通信環境を構築できるようシェアして頂いたダイコンさん   
参考GitHub：   
nishimoto265/Claude-Code-Communication   
　　URL: https://github.com/nishimoto265/Claude-Code-Communication   
    
・ ダイコン（@daikon265）さん / X   
　　URL: https://x.com/daikon265   
    
◇Claude Code公式解説動画：   
Mastering Claude Code in 30 minutes - YouTube   
　　URL: https://www.youtube.com/live/6eBSHbLKuN0?t=1356s