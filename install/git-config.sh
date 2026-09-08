# Global git identity.

name="$(pref_str git_user_name)"
email="$(pref_str git_user_email)"

if [[ -n $name && $name != "Your Name" ]]; then
  git config --global user.name "$name"
  ok "user.name = $name"
else
  skip "git_user_name not set in preferences.json"
fi

if [[ -n $email && $email != "your.email@example.com" ]]; then
  git config --global user.email "$email"
  ok "user.email = $email"
else
  skip "git_user_email not set in preferences.json"
fi
