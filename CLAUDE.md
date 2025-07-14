# Agent Communication System (Gemini CLI)

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者 - Gemini CLIで動作
- **boss1** (multiagent:0.0): チームリーダー - Gemini CLIで動作
- **worker1,2,3** (multiagent:0.1-3): 実行担当 - Gemini CLIで動作

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT

## Gemini CLI 特有の注意事項
- 認証は各セッションで個別に必要
- レスポンス形式はClaude Codeとは異なる場合がある
- ツール利用可能性を確認して使用 