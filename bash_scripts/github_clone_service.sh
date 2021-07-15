ssh_username=$ssh_username
project_name=$project_name
github_username=$github_username
github_token=$github_token
repo_name=$repo_name

# ssh_username=$1
# project_name=$2
# github_username=$3
# github_token=$4
# repo_name=$5

mkdir -p /home/$ssh_username/$project_name
cd /home/$ssh_username/$project_name
git clone https://$github_username:$github_token@github.com/$github_username/$repo_name.git