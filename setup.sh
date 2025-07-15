#!/bin/bash

# 🚀 Gemini CLI エージェント通信システム - 統合セットアップ
# プロジェクト選択 → 環境構築 → エージェント起動

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

echo "🚀 Gemini CLI エージェント通信システム - 環境構築"
echo "============================================="
echo ""

# 必要なスクリプトの存在確認
check_requirements() {
    local required_files=("project-manager.sh" "launch-president.sh" "launch-team.sh")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "./$file" ]; then
            log_error "必要なファイルが見つかりません: $file"
            exit 1
        fi
        
        if [ ! -x "./$file" ]; then
            log_warning "$file に実行権限がありません。権限を付与します..."
            chmod +x "./$file"
        fi
    done
}

# プロジェクト選択
select_project_step() {
    echo "📂 STEP 1: プロジェクト選択"
    echo "========================="
    echo ""
    
    # プロジェクト選択実行
    if ! ./project-manager.sh; then
        log_error "プロジェクト選択がキャンセルされました"
        exit 1
    fi
    
    echo ""
    log_success "✅ プロジェクト選択完了"
    
    # 選択されたプロジェクトを表示
    ./project-manager.sh current
    echo ""
}

# tmuxセッション作成
create_tmux_sessions() {
    echo "📺 STEP 2: tmuxセッション作成"
    echo "============================"
    echo ""
    
    # 既存セッションクリーンアップ
    log_info "🧹 既存セッションクリーンアップ開始..."
    
    tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
    tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"
    
    # 完了ファイルクリア
    mkdir -p ./tmp
    rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"
    
    log_success "✅ クリーンアップ完了"
    echo ""
    
    # multiagentセッション作成（4ペイン：boss1 + worker1,2,3）
    log_info "📺 multiagentセッション作成開始 (4ペイン)..."

    # 最初のペイン作成
    tmux new-session -d -s multiagent -n "agents"
    
    # 2x2グリッド作成（合計4ペイン）
    tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
    tmux select-pane -t "multiagent:0.0"
    tmux split-window -v                        # 左側を垂直分割
    tmux select-pane -t "multiagent:0.2"
    tmux split-window -v                        # 右側を垂直分割
    
    # ペインタイトル設定
    log_info "ペインタイトル設定中..."
    PANE_TITLES=("boss1" "worker1" "worker2" "worker3")
    
    for i in {0..3}; do
        tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
        
        # 作業ディレクトリ設定
        tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
        
        # カラープロンプト設定
        if [ $i -eq 0 ]; then
            # boss1: 赤色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
        else
            # workers: 青色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
        fi
        
        # ウェルカムメッセージ
        tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
    done
    
    log_success "✅ multiagentセッション作成完了"
    echo ""
    
    # presidentセッション作成（1ペイン）
    log_info "👑 presidentセッション作成開始..."
    
    tmux new-session -d -s president
    tmux send-keys -t president "cd $(pwd)" C-m
    tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    tmux send-keys -t president "echo '=== PRESIDENT セッション ==='" C-m
    tmux send-keys -t president "echo 'プロジェクト統括責任者'" C-m
    tmux send-keys -t president "echo '========================'" C-m
    
    log_success "✅ presidentセッション作成完了"
    echo ""
}

# セットアップ完了情報表示
show_setup_completion() {
    echo ""
    log_success "✅ セットアップ完了"
    
    # tmuxセッション確認
    echo ""
    echo "📺 作成されたTmuxセッション:"
    tmux list-sessions
    echo ""
    
    # ペイン構成表示
    echo "📋 ペイン構成:"
    echo "  multiagentセッション（4ペイン）:"
    echo "    Pane 0: boss1     (チームリーダー)"
    echo "    Pane 1: worker1   (実行担当者A)"
    echo "    Pane 2: worker2   (実行担当者B)"
    echo "    Pane 3: worker3   (実行担当者C)"
    echo ""
    echo "  presidentセッション（1ペイン）:"
    echo "    Pane 0: PRESIDENT (プロジェクト統括)"
    
    echo ""
    echo "📋 次のステップ:"
    echo "  PRESIDENT起動: ./launch-president.sh"
    echo "  チーム起動:     ./launch-team.sh"
    echo ""
    echo "画面接続:"
    echo "  tmux attach-session -t president   # PRESIDENT画面"
    echo "  tmux attach-session -t multiagent  # チーム画面"
}



# オプション解析
PROJECT_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# ヘルプ表示
show_help() {
    cat << 'EOF'
🚀 Gemini CLI エージェント通信システム - 環境構築

使用方法:
  ./setup.sh                              # 対話式起動（推奨）
  ./setup.sh --project [プロジェクト名]    # プロジェクト指定起動

例:
  ./setup.sh                              # 対話式でプロジェクト選択→環境構築
  ./setup.sh --project programming-organization   # 指定プロジェクトで環境構築

必要な環境:
  - tmux
  - Gemini CLI
  - ./projects/ ディレクトリにプロジェクト

EOF
}

# メイン処理
main() {
    # 事前チェック
    check_requirements
    
    # プロジェクト選択
    if [ -n "$PROJECT_NAME" ]; then
        # プロジェクト名指定
        echo "📂 指定プロジェクト: $PROJECT_NAME"
        if ! ./project-manager.sh select "$PROJECT_NAME"; then
            log_error "プロジェクト '$PROJECT_NAME' の選択に失敗しました"
            exit 1
        fi
        echo ""
    else
        # 対話式選択
        select_project_step
    fi
    
    # tmuxセッション作成
    create_tmux_sessions
    
    # セットアップ完了表示
    show_setup_completion
}

# 実行
main "$@" 