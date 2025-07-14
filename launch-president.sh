#!/bin/bash

# 👑 PRESIDENT単独起動スクリプト
# プロジェクト統括責任者を起動

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

echo "👑 PRESIDENT起動スクリプト"
echo "========================="
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

# presidentセッション確認・作成
setup_president_session() {
    if tmux has-session -t president 2>/dev/null; then
        log_warning "presidentセッションが既に存在します"
        
        read -p "既存セッションを削除して再作成しますか？ (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            log_info "既存セッションを削除中..."
            tmux kill-session -t president
        else
            log_info "既存セッションを使用します"
            return 0
        fi
    fi
    
    log_info "presidentセッションを作成中..."
    tmux new-session -d -s president
    log_success "presidentセッション作成完了"
}

# PRESIDENT起動
launch_president() {
    log_info "PRESIDENT（統括責任者）を起動中（自動承認モード）..."
    
    # Gemini CLI起動
    tmux send-keys -t president 'gemini -y' C-m
    sleep 1
    
    log_success "PRESIDENT起動コマンド送信完了"
}

# 使用方法表示
show_usage() {
    cat << 'EOF'

📋 PRESIDENTの使用方法:

1. 認証完了後、以下のメッセージで起動:
   「あなたはPRESIDENTです。instructions/president.mdに従って行動してください。」

2. プロジェクト指示例:
   「カフェのホームページを作成してください。モダンなデザインで、React + TypeScript + Tailwind CSSを使用。」

3. PRESIDENT画面に接続:
   tmux attach-session -t president

4. PRESIDENTへメッセージ送信:
   ./agent-send.sh president "メッセージ内容"

💡 ヒント:
- PRESIDENTは自動的にboss1にタスクを委任します
- 進捗確認は定期的に行われます
- 問題があれば即座に報告されます

EOF
}

# メイン処理
main() {
    echo "📋 起動準備:"
    echo "  - PRESIDENT（プロジェクト統括責任者）"
    echo ""
    
    # 環境確認
    check_tmux
    check_gemini
    
    # セッション設定
    setup_president_session
    
    # 起動確認
    read -p "PRESIDENTを起動しますか？ (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "キャンセルしました"
        exit 0
    fi
    
    echo ""
    log_info "PRESIDENT起動を開始します..."
    echo ""
    
    # PRESIDENT起動
    launch_president
    
    echo ""
    log_success "✅ PRESIDENT起動完了！"
    echo ""
    echo "✨ 自動承認モード（-y）で起動済み - 確認プロンプトは自動でYESになります"
    
    # 使用方法表示
    show_usage
}

# ヘルプ表示
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "👑 PRESIDENT起動スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0          # PRESIDENT起動"
    echo "  $0 --help   # ヘルプ表示"
    echo ""
    echo "PRESIDENTの役割:"
    echo "  - プロジェクトマネージャー"
    echo "  - クライアント要件の明確化"
    echo "  - チームへのタスク指示"
    echo "  - 進捗管理と品質保証"
    exit 0
fi

# 実行
main "$@"