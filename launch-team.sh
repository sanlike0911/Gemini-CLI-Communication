#!/bin/bash

# 🎯 チーム（boss1 + workers）起動スクリプト
# boss1（チームリーダー）とworker1-3（実行担当者）を一括起動

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

echo "🎯 チーム起動スクリプト"
echo "======================="
echo ""

# tmux環境確認
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        log_error "tmuxがインストールされていません"
        echo "インストール: sudo apt install tmux"
        exit 1
    fi
}

# Gemini CLI確認
check_gemini() {
    if ! command -v gemini &> /dev/null; then
        log_error "Gemini CLIがインストールされていません"
        echo "インストール: npm install -g @google-ai/gemini-cli"
        exit 1
    fi
}

# multiagentセッション確認・作成
setup_multiagent_session() {
    if ! tmux has-session -t multiagent 2>/dev/null; then
        log_error "multiagentセッションが存在しません"
        echo ""
        echo "🔧 環境セットアップが必要です:"
        echo "   ./setup.sh"
        echo ""
        echo "セットアップ後、再度このスクリプトを実行してください。"
        exit 1
    fi
    
    log_info "既存のmultiagentセッションを使用します"
}

# チームメンバー起動
launch_team_member() {
    local pane_id=$1
    local member_name=$2
    local target="multiagent:0.$pane_id"
    
    log_info "$member_name を起動中（自動承認モード）..."
    
    # ペインにフォーカス
    tmux select-pane -t "$target"
    
    # コンフィグベースでGemini CLI起動
    local model=$(jq -r ".model" "./gemini-config.json" 2>/dev/null || echo "gemini-2.5-flash")
    tmux send-keys -t "$target" "gemini -m '$model' -y" C-m
    sleep 0.5
    
    log_success "$member_name 起動コマンド送信完了"
}

# 全チーム起動
launch_all_team() {
    echo "🚀 チーム起動シーケンス開始..."
    echo ""
    
    # boss1起動（ペイン0）
    launch_team_member 0 "boss1（チームリーダー）"
    
    # worker1起動（ペイン1）
    launch_team_member 1 "worker1（実行担当者A）"
    
    # worker2起動（ペイン2）
    launch_team_member 2 "worker2（実行担当者B）"
    
    # worker3起動（ペイン3）
    launch_team_member 3 "worker3（実行担当者C）"
    
    echo ""
    log_success "✅ 全チームメンバーの起動コマンド送信完了"
}

# 使用方法表示
show_usage() {
    cat << 'EOF'

📋 チームの使用方法:

1. 各メンバーの認証完了後、それぞれに役割を通知:

   boss1への指示:
   「あなたはboss1です。instructions/boss.mdに従って行動してください。」

   worker1への指示:
   「あなたはworker1です。instructions/worker.mdに従って行動してください。」

   worker2への指示:
   「あなたはworker2です。instructions/worker.mdに従って行動してください。」

   worker3への指示:
   「あなたはworker3です。instructions/worker.mdに従って行動してください。」

2. チーム画面に接続:
   tmux attach-session -t multiagent

3. 各メンバーへのメッセージ送信:
   ./agent-send.sh boss1 "メッセージ内容"
   ./agent-send.sh worker1 "メッセージ内容"
   ./agent-send.sh worker2 "メッセージ内容"
   ./agent-send.sh worker3 "メッセージ内容"

4. ペイン切り替え（tmux内で）:
   Ctrl+b → 矢印キー（上下左右でペイン移動）

💡 ワークフロー:
PRESIDENT → boss1 → workers → boss1 → PRESIDENT

🎯 各メンバーの役割:
- boss1: テックリード（技術統括、タスク分解、進捗管理）
- worker1: フロントエンド担当
- worker2: バックエンド担当  
- worker3: インフラ/DevOps担当

EOF
}

# ペイン配置情報表示
show_pane_layout() {
    cat << 'EOF'

🖥️  チーム画面レイアウト:

┌─────────────┬─────────────┐
│             │             │
│    boss1    │   worker1   │
│ (ペイン 0)   │ (ペイン 1)   │
│             │             │
├─────────────┼─────────────┤
│             │             │
│   worker3   │   worker2   │
│ (ペイン 3)   │ (ペイン 2)   │
│             │             │
└─────────────┴─────────────┘

EOF
}

# メイン処理
main() {
    echo "📋 起動準備:"
    echo "  - boss1（チームリーダー）"
    echo "  - worker1（実行担当者A）"
    echo "  - worker2（実行担当者B）"
    echo "  - worker3（実行担当者C）"
    echo ""
    
    # 環境確認
    check_tmux
    check_gemini
    
    # セッション設定
    setup_multiagent_session
    
    # レイアウト情報表示
    show_pane_layout
    
    # 起動確認
    read -p "全チームメンバーを起動しますか？ (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "キャンセルしました"
        exit 0
    fi
    
    echo ""
    log_info "チーム起動を開始します..."
    echo ""
    
    # チーム起動
    launch_all_team
    
    echo ""
    echo "✨ 自動承認モード（-y）で起動済み - 確認プロンプトは自動でYESになります"
    
    # 使用方法表示
    show_usage
    
    echo ""
    log_info "チーム画面に接続しています..."
    
    # tmuxセッションに接続（4画面表示）
    tmux attach-session -t multiagent
}

# ヘルプ表示
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "🎯 チーム起動スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0          # チーム起動"
    echo "  $0 --help   # ヘルプ表示"
    echo ""
    echo "チームメンバー:"
    echo "  boss1   - チームリーダー（技術統括）"
    echo "  worker1 - 実行担当者A（フロントエンド）"
    echo "  worker2 - 実行担当者B（バックエンド）"
    echo "  worker3 - 実行担当者C（インフラ/DevOps）"
    echo ""
    echo "起動後の画面:"
    echo "  4分割されたペインに各メンバーが配置されます"
    show_pane_layout
    exit 0
fi

# 実行
main "$@"