import os

DEFAULT_CLONE_PATH = "/tmp"

class GithubClone(object):
    """
        A Github Class to clone files
    """

    def __init__(self, username, token, repo_name, exec_path=DEFAULT_CLONE_PATH):

        self.username = username
        self.token = token
        self.repo_name = repo_name
        self.exec_path = exec_path

        if not os.path.isdir(self.exec_path):
            raise OSError('Git Clone Path not found at path: {0}'.format(self.exec_path))

    def clone(self):
        os.chdir(self.exec_path)
        cmd = "git clone https://{0}:{1}@github.com/{0}/{2}.git".format(self.username, self.token, self.repo_name)
        os.system(cmd)

    def post_file_process(self):
        pass


if __name__ == '__main__':
    username = os.environ.get("GITHUB_USERNAME", "your-username")
    token = os.environ.get("GITHUB_TOKEN", "your-token")
    repo_name = os.environ.get("GITHUB_REPO", "your-repo")

    github = GithubClone(username, token, repo_name)
    github.clone()