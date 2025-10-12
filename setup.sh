#!/usr/bin/env bash
set -euo pipefail

FILES=(
	".config"
	".gitconfig"
	".tmux.conf"
	".zprofile"
	".zshrc"
)

function _install() {
	local _force="${1}"

	local _file _target
	for _file in "${FILES[@]}"; do
		_target="$HOME/${_file}"

		if [[ -e "${_target}" || -L "${_target}" ]]; then
			if [[ "${_force}" -eq 1 ]]; then
				rm -rf "${_target}"
				echo "⚡ Overwriting existing: ${_file}" >&2
			else
				echo "⚠️ Skipping ${_file}, already exists: ${_target}" >&2
				continue
			fi
		fi

		ln -sf "$PWD/${_file}" "${_target}"
		echo "🔗 Linked: ${_file}" >&2
	done

	echo "✅ All symlinks created!" >&2
}

function _uninstall() {
	local _file
	for _file in "${FILES[@]}"; do
		if [[ -L "$HOME/${_file}" ]]; then
			rm "$HOME/${_file}"
			echo "❌ Removed symlink: ${_file}" >&2
		else
			echo "⚠️ Not a symlink or does not exist: ${_file}" >&2
		fi
	done

	echo "✅ All symlinks removed!" >&2
}

function _show_help() {
	echo "Usage: ${0} [-h] [-f] [install|uninstall]"
	echo ""
	echo "Commands:"
	echo "  install   Creates symlinks at $HOME"
	echo "  uninstall Removes symlinks at $HOME"
	echo "Target files:"
	echo "$(printf -- "  - %s\n" "${FILES[@]}")"
	echo "Options:"
	echo "  -h        Shows this help message"
	echo "  -f        Overwrites exsiting files or directories when creating symlinkns (install only)"
}

function main() {
	local _force=0
	while getopts "hf" _opt; do
		case "${_opt}" in
		h)
			_show_help
			return 0
			;;
		f)
			_force=1
			;;
		*)
			_show_help
			return 0
			;;
		esac
	done
	shift $((OPTIND - 1))

	local _subcommand="${1}"
	case "${_subcommand}" in
	install) _install "${_force}" ;;
	uninstall) _uninstall ;;
	*) _show_help ;;
	esac
}

main "${@:-}"
