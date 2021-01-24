#! /bin/bash

repodir="${REPODIR:-"$(git rev-parse --show-toplevel)"}"
appdir="${APPDIR:-"$(mktemp --tmpdir --directory AppDir.XXXXXXXX)"}"
count=0
failed=0

run_valid_command() {
	((count++))
	if out="$("$@" 2>&1 )"; then
		echo -e "[\033[1;32m  OK  \033[0m]"
	else
		echo -e "[\033[1;31mFAILED\033[0m]"
		((failed++))
		echo "$out"
	fi
}

run_invalid_command() {
	((count++))
	if out="$("$@" 2>&1 )"; then
		echo -e "[\033[1;31mFAILED\033[0m]"
		((failed++))
		echo "$out"
	else
		echo -e "[\033[1;32m  OK  \033[0m]"
	fi
}

while IFS= read -r -d '' plugin; do
	name="$(basename "$plugin")"
	echo -e "\033[1mTesting plugin $name...\033[0m"

	printf "%-60s" " - lint plugin"
	run_valid_command shellcheck "$plugin"

	printf "%-60s" " - run with wrong usage"
	run_invalid_command bash "$plugin"

	printf "%-60s" " - run with --plugin-api-version"
	run_valid_command bash "$plugin" --plugin-api-version

	printf "%-60s" " - run with --appdir"
	env="$(dirname "$plugin")/.test.env"
	if [ -f "$env" ]; then
		# shellcheck disable=SC1090
		(set -o allexport; source "$env"; run_valid_command bash "$plugin" --appdir "$appdir")
	else
		run_valid_command bash "$plugin" --appdir "$appdir"
	fi

	hook="$appdir/apprun-hooks/$name"
	if [ -f "$hook" ]; then
		printf "%-60s" " - lint apprun-hook"
		run_valid_command shellcheck -s sh "$hook"
	fi

	echo
done < <(find "$repodir" -name 'linuxdeploy-plugin-*.sh' -print0)

if [ "$failed" -eq 0 ]; then
	echo -e "\033[1;32mAll $count tests passed with success!\033[0m"
else
	echo -e "\033[1;31mError: $failed tests failed.\033[0m"
fi
exit "$failed"
