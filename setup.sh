#!/usr/bin/env bash
set -euo pipefail

function _info() {
	echo "${@}" >&2
}

function _script_dir() {
	local _script_dir
	_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	echo "${_script_dir}"
}

## _target_files returns the list of target files/directories to create/remove symlinks.
## Returns:
##   Prints each file/directory on a seperate line
function _target_files() {
	local _files=(
		".config"
		".gitconfig"
		".tmux.conf"
		".zprofile"
		".zshrc"
	)

	printf "$(_script_dir)/%s\n" "${_files[@]}"
}

## _install creates symlinks pointing to files/directories at the home directory.
## Arguments:
##   $1 - force flag; 0 for skipping existing files, 1 for overwriting them
##   $@ - the list of files/directories to link
function _install() {
	local _force="${1}"
	shift
	local _files=("${@}")

	local _file _target
	for _file in "${_files[@]}"; do
		if [[ ! -e "${_file}" ]]; then
			_info "File or directory not found: ${_file}"
			return 1
		fi

		_target="$HOME/$(basename "${_file}")"

		if [[ -e "${_target}" || -L "${_target}" ]]; then
			if [[ "${_force}" -eq 1 ]]; then
				rm -rf "${_target}"
				_info "⚡ Overwriting existing: ${_target}"
			else
				_info "⚠️ Skipping ${_file}, already exists: ${_target}"
				continue
			fi
		fi

		ln -sf "${_file}" "${_target}"
		_info "🔗 Linked: ${_file}"
	done

	_info "✅ All symlinks created!"
}

## _uninstall deletes symlinks pointing to files/directories at the home directory.
## Arguments:
##   $@ - the list of files/directories to link
function _uninstall() {
	local _files=("${@}")

	local _file _target
	for _file in "${_files[@]}"; do
		_target="$HOME/$(basename "${_file}")"
		if [[ -L "${_target}" ]]; then
			rm "${_target}"
			_info "❌ Removed symlink: ${_target}"
		else
			_info "⚠️ Not a symlink or does not exist: ${_target}"
		fi
	done

	_info "✅ All symlinks removed!"
}

function _show_help() {
	local _files=()
	while IFS= read -r _file; do
		_files+=("${_file}")
	done < <(_target_files)

	echo "Usage: ${0} [-h] [-f] [install|uninstall]"
	echo ""
	echo "Commands:"
	echo "  install   Creates symlinks at $HOME"
	echo "  uninstall Removes symlinks at $HOME"
	echo "Target files:"
	echo "$(printf -- "  - %s\n" "${_files[@]}")"
	echo "Options:"
	echo "  -h        Shows this help message"
	echo "  -f        Forcibly overwrites exsiting files or directories when creating symlinkns (install only)"
	echo "  -t        Specifies the target files or directories to be replaced with symlinks"
}

function main() {
	local _force=0 _help=0 _targets=() _parsing_target=0 _subcommand=""
	while [[ "${#}" -gt 0 ]]; do
		case "${1}" in
		-h)
			_parsing_target=0
			_help=1
			;;
		-f)
			_parsing_target=0
			_force=1
			;;
		-t)
			_parsing_target=1
			;;
		install | uninstall)
			_parsing_target=0
			_subcommand="${1}"
			;;
		*)
			if [[ "${_parsing_target}" -eq 1 ]]; then
				if [[ "${1}" == /* ]]; then
					_targets+=("${1}")
				else
					_targets+=("$(pwd)/${1}")
				fi
			else
				_info "invalid args: ${1}"
				return 1
			fi
			;;
		esac
		shift
	done

	if [[ "${_help}" -eq 1 ]]; then
		_show_help
		return 0
	fi

	if [[ "${#_targets[@]}" -eq 0 ]]; then
		while IFS= read -r _file; do
			_targets+=("${_file}")
		done < <(_target_files)
	fi

	(
		cd "$(_script_dir)"

		case "${_subcommand}" in
		install) _install "${_force}" "${_targets[@]}" || exit 1 ;;
		uninstall) _uninstall "${_targets[@]}" || exit 1 ;;
		*)
			echo "invalid subcommand: ${_subcommand}"
			exit 1
			;;
		esac
	) || return 1
}

main "${@:-}"
