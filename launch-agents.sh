#!/bin/bash

# 🚀 AIエージェント一括起動スクリプト
# claude --dangerously-skip-permissions フラグ付きで全エージェントを起動

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

echo "🤖 AIエージェント一括起動"
echo "=========================="
echo ""

# セッション存在確認
check_sessions() {
    local all_exist=true
    
    if ! tmux has-session -t president 2>/dev/null; then
        log_warning "presidentセッションが存在しません"
        all_exist=false
    fi
    
    if ! tmux has-session -t multiagent 2>/dev/null; then
        log_warning "multiagentセッションが存在しません"
        all_exist=false
    fi
    
    if [ "$all_exist" = false ]; then
        echo ""
        echo "❌ 必要なセッションが見つかりません"
        echo "   先に ./setup.sh を実行してください"
        exit 1
    fi
}

# エージェント起動関数
launch_agent() {
    local target=$1
    local name=$2
    
    log_info "$name を起動中..."
    tmux send-keys -t "$target" 'claude --dangerously-skip-permissions' C-m
    sleep 0.5
}

# メイン処理
main() {
    # セッション確認
    check_sessions
    
    echo "📋 起動するエージェント:"
    echo "  - PRESIDENT (統括責任者)"
    echo "  - boss1 (チームリーダー)"
    echo "  - worker1, 2, 3 (実行担当者)"
    echo ""
    
    # 起動確認
    read -p "全エージェントを起動しますか？ (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "キャンセルしました"
        exit 0
    fi
    
    echo ""
    log_info "起動を開始します..."
    echo ""
    
    # PRESIDENT起動
    launch_agent "president" "PRESIDENT"
    
    # boss1起動
    launch_agent "multiagent:0.0" "boss1"
    
    # workers起動
    launch_agent "multiagent:0.1" "worker1"
    launch_agent "multiagent:0.2" "worker2"
    launch_agent "multiagent:0.3" "worker3"
    
    echo ""
    log_success "✅ 全エージェントの起動コマンドを送信しました"
    echo ""
    echo "📋 次のステップ:"
    echo "  1. 各画面でブラウザ認証を完了してください"
    echo "  2. PRESIDENTに指示を送信:"
    echo "     「あなたはpresidentです。[プロジェクト内容]」"
    echo ""
    echo "💡 画面を確認:"
    echo "  tmux attach-session -t president    # 社長画面"
    echo "  tmux attach-session -t multiagent   # 部下たち画面"
}

# 実行
main "$@"