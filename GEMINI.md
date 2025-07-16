# Agent Communication System

## エージェント構成

- **president** (singleagent): 社長
- **boss1** (multiagent:0.0): チームリーダー
- **worker1** (multiagent:0.1): 実行担当者1
- **worker2** (multiagent:0.2): 実行担当者2
- **worker3** (multiagent:0.3): 実行担当者3

## あなたの役割

- **president**: @instructions/projects/software-development/president.md
- **boss1**: @instructions/projects/software-development/boss.md
- **worker1**: @instructions/projects/software-development/worker.md
- **worker2**: @instructions/projects/software-development/worker.md
- **worker3**: @instructions/projects/software-development/worker.md

## メッセージ送信

```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 成果物の保存先

あなたの成果物は、以下のディレクトリに保存してください。

```bash
./projects/[プロジェクト名]/workspace/
```

## 基本フロー

PRESIDENT → boss1 → workers → boss1 → PRESIDENT
