#!/bin/zsh

if [ "$1" = "" ]; then
  echo "Run this script with your email address: ./ssh.sh mats@example.com" && exit 1
fi

echo "Generating a new GitHub SSH key for $1..."

# Generating SSH key - https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
ssh-keygen -t ed25519 -C $1 -f ~/.ssh/id_ed25519 -N ""

# Add key to the ssh-agent https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
eval "$(ssh-agent -s)"

touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

ssh-add --apple-use-keychain --apple-load-keychain ~/.ssh/id_ed25519

# Add SSH key to your GitHub account
echo "
✅ SSH key is generatred!
Now, run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste the public key into GitHub: https://github.com/settings/keyss

📝 Remember to add it as both 'Authentication Key' and 'Signing Key'! 
"
