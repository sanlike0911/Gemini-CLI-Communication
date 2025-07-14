# 🤖 Gemini CLI エージェント通信システム

複数のAIが協力して働く、まるで会社のような開発システムです（Gemini CLI版）

## 📌 これは何？

**3行で説明すると：**
1. 複数のAIエージェント（社長・マネージャー・作業者）が協力して開発
2. それぞれ異なるターミナル画面で動作し、メッセージを送り合う
3. 人間の組織のように役割分担して、効率的に開発を進める

**実際の成果：**
- 3時間で完成したアンケートシステム（EmotiFlow）
- 12個の革新的アイデアを生成
- 100%のテストカバレッジ

## 🎬 5分で動かしてみよう！

### 必要なもの
- Mac または Linux
- tmux（ターミナル分割ツール）
- Gemini CLI

### 手順

#### 1️⃣ ダウンロード（30秒）
```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

#### 2️⃣ 環境構築（1分）
```bash
./setup.sh
```
これでバックグラウンドに5つのターミナル画面が準備されます！

#### 3️⃣ 社長画面を開いてAI起動（2分）

**社長画面を開く：**
```bash
tmux attach-session -t president
```

**社長画面でGemini CLIを起動：**
```bash
# 認証が必要
gemini
```

#### 4️⃣ 部下たちを一括起動（1分）

**新しいターミナルを開いて：**
```bash
# 4人の部下を一括起動
for i in {0..3}; do 
  tmux send-keys -t multiagent.$i 'gemini' C-m
done
```

#### 5️⃣ 部下たちの画面を確認
・各画面でGemini CLIの認証が必要な場合あり
```bash
tmux attach-session -t multiagent
```
これで4分割された画面が表示されます：
```
┌────────┬────────┐
│ boss1  │worker1 │
├────────┼────────┤
│worker2 │worker3 │
└────────┴────────┘
```

#### 6️⃣ 魔法の言葉を入力（30秒）

そして入力：
```
あなたはpresidentです。おしゃれな充実したIT企業のホームページを作成して。
```

**すると自動的に：**
1. 社長がマネージャーに指示
2. マネージャーが3人の作業者に仕事を割り振り
3. みんなで協力して開発
4. 完成したら社長に報告

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
- **worker1**: デザイン担当（UI/UX）
- **worker2**: データ処理担当
- **worker3**: テスト担当

## 💬 どうやってコミュニケーションする？

### メッセージの送り方
```bash
./agent-send.sh [相手の名前] "[メッセージ]"

# 例：マネージャーに送る
./agent-send.sh boss1 "新しいプロジェクトです"

# 例：作業者1に送る
./agent-send.sh worker1 "UIを作ってください"
```

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

## 📁 重要なファイルの説明

### 指示書（instructions/）
各エージェントの行動マニュアルです

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

### CLAUDE.md
システム全体の設定ファイル
```markdown
# Agent Communication System

## エージェント構成
- PRESIDENT: 統括責任者
- boss1: チームリーダー  
- worker1,2,3: 実行担当

## メッセージ送信
./agent-send.sh [相手] "[メッセージ]"
```

## 🎨 実際に作られたもの：EmotiFlow

### 何ができた？
- 😊 絵文字で感情を表現できるアンケート
- 📊 リアルタイムで結果が見られる
- 📱 スマホでも使える

### 試してみる
```bash
cd emotiflow-mvp
python -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### ファイル構成
```
emotiflow-mvp/
├── index.html    # メイン画面
├── styles.css    # デザイン
├── script.js     # 動作ロジック
└── tests/        # テスト
```

## 🔧 困ったときは

### Q: エージェントが反応しない
```bash
# 状態を確認
tmux ls

# 再起動
./setup.sh
```

### Q: メッセージが届かない
```bash
# ログを見る
cat logs/send_log.txt

# 手動でテスト
./agent-send.sh boss1 "テスト"
```

### Q: 最初からやり直したい
```bash
# 全部リセット
tmux kill-server
rm -rf ./tmp/*
./setup.sh
```

## 🚀 自分のプロジェクトを作る

### 簡単な例：TODOアプリを作る

社長（PRESIDENT）で入力：
```
あなたはpresidentです。
TODOアプリを作ってください。
シンプルで使いやすく、タスクの追加・削除・完了ができるものです。
```

すると自動的に：
1. マネージャーがタスクを分解
2. worker1がUI作成
3. worker2がデータ管理
4. worker3がテスト作成
5. 完成！

## 📊 システムの仕組み（図解）

### 画面構成
```
┌─────────────────┐
│   PRESIDENT     │ ← 社長の画面（紫色）
└─────────────────┘

┌────────┬────────┐
│ boss1  │worker1 │ ← マネージャー（赤）と作業者1（青）
├────────┼────────┤
│worker2 │worker3 │ ← 作業者2と3（青）
└────────┴────────┘
```

### コミュニケーションの流れ
```
社長
 ↓ 「ビジョンを実現して」
マネージャー
 ↓ 「みんな、アイデア出して」
作業者たち
 ↓ 「できました！」
マネージャー
 ↓ 「全員完了です」
社長
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

## 🎓 もっと詳しく知りたい人へ

### プロンプトの書き方

**良い例：**
```
あなたはboss1です。

【プロジェクト名】明確な名前
【ビジョン】具体的な理想
【成功基準】測定可能な指標
```

**悪い例：**
```
何か作って
```

### カスタマイズ方法

**新しい作業者を追加：**
1. `instructions/worker4.md`を作成
2. `setup.sh`を編集してペインを追加
3. `agent-send.sh`にマッピングを追加

**タイマーを変更：**
```bash
# instructions/boss.md の中の
sleep 600  # 10分を5分に変更するなら
sleep 300
```

## 🌟 まとめ

このシステムは、複数のAIが協力することで：
- **3時間**で本格的なWebアプリが完成
- **12個**の革新的アイデアを生成
- **100%**のテストカバレッジを実現

ぜひ試してみて、AIチームの力を体験してください！

---

**作者**: [GitHub](https://github.com/nishimoto265/Claude-Code-Communication)
**ライセンス**: MIT
**質問**: [Issues](https://github.com/nishimoto265/Claude-Code-Communication/issues)へどうぞ！


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
   
