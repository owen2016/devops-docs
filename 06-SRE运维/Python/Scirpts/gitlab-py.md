# gitlab-py


```
import os
import gitlab

gl = gitlab.Gitlab('http://gitlab_hostname.com', 'your_private_token')
groups = gl.groups.list()
projects = gl.projects.list()
all_projects = gl.projects.list(all=True)
all_groups=gl.groups.list(all=True)
print("All groups are:",all_groups)
length=len(all_projects)
i=0
while i < length:
    project = gl.projects.get(all_projects[i].id)
    print(project)
    i=i+1

```


```
import os
import gitlab

gl = gitlab.Gitlab('http://gitlab_hostname.com', 'your_private_token')
all_projects = gl.projects.list(all=True)
print("All projects id are:",all_projects)

```