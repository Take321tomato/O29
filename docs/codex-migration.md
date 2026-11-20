# Codex → Claude Code 移行ガイド

移行元: `C:\Users\logic\.codex`（Codex CLI の設定・履歴フォルダ）

## 1. `.codex` の中身と扱い

| 項目 | 内容 | リスク | 移行先 (Claude Code) |
|---|---|---|---|
| `auth.json` | OpenAI の API キー / ログイントークン | **高**: 漏れると不正利用される | **移行しない・共有しない** |
| `config.toml` | モデル・承認ポリシー・MCP サーバー設定 | 中: MCP の `env` にトークンが入っていることがある | `~/.claude/settings.json`、MCP は `claude mcp add` |
| `AGENTS.md` | 全体共通の指示 | 低 | `~/.claude/CLAUDE.md` |
| `prompts/*.md` | カスタムプロンプト（/コマンド） | 低 | `~/.claude/commands/*.md` |
| `skills/` | スキル | 低 | `~/.claude/skills/<名前>/SKILL.md`（形式ほぼ互換） |
| `rules/` | コマンド実行の許可ルール | 低 | `settings.json` の `permissions.allow / deny` |
| `history.jsonl`, `sessions/` | 過去の会話ログ | 中〜高: コード・個人情報・貼り付けたキーが残っている可能性 | 移行は不要。活動内容の分析にだけ使う |
| `log/`, キャッシュ類 | ログ | 低〜中 | 移行しない |

## 2. 手順

1. **安全なコピーを作る**（PC の PowerShell で実行）
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\export-codex.ps1
   # 会話履歴も分析したい場合のみ:
   powershell -ExecutionPolicy Bypass -File .\tools\export-codex.ps1 -IncludeHistory
   ```
   - `C:\Users\logic\codex-export` に許可リストのファイルだけをコピーする
   - `auth.json` はコピーしない。キーらしい文字列は `<REDACTED>` に置き換える
   - 置き換えは完全ではないので、共有前に中身を目で確認する
2. **Claude から読めるようにする**（どちらか）
   - A（おすすめ）: PC の Claude デスクトップアプリで Claude Code を開き、`codex-export` フォルダで作業する
   - B: デスクトップアプリの 設定 → Claude Code → Remote Control に `codex-export` を追加し、スマホのクラウドセッションから接続する
     （`.codex` は隠しフォルダなので直接は接続できない）
3. **Claude が分析・変換する**: 活動内容のまとめを作り、`CLAUDE.md` / commands / skills / settings を作成する
4. **MCP のキーを入れ直す**: マスクしたトークンは、ユーザーが自分で `claude mcp add ... -e KEY=...` で設定する
