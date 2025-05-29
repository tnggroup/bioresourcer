Working with the command line and computation cluster
============================================
Reference sheet version 5 (20250103)

Johan Zvrskovec 2025

# Generate secure SSH keys
As of 2024:
https://security.stackexchange.com/questions/143442/what-are-ssh-keygen-best-practices

    ssh-keygen -t ed25519 -a 100 -f mykey.eddsa
  

# Connect to Create: remote access with ssh
Connecting with your user (use your k-username), using a specified private keyfile (identity file) (1) or when you have set up your keys in ~/.ssh/config (2)
    
    ssh -i ~/mykey.rsa kXXXXXXXX@hpc.create.kcl.ac.uk    #1
    
    ssh kXXXXXXXX@hpc.create.kcl.ac.uk                   #2

KCL research software and Create support forum at: https://forum.er.kcl.ac.uk/
(because I always have trouble finding this)

# File areas on Create
Personal - for scripts, logs, and programs:
    
    /users/kXXXXXXXX

Scratch - for data files and other larger files:
    
    /scratch/users/kXXXXXXXX

# General Linux command line

## General commands
    
    cd                    #change directory
    pwd                   #show current directory path
    ls                    #list directory content - also see 'find' below
    ps aux                #list running processes - example: all, usage statistics, processes not executed from the terminal
    cat                   #print content of file
    myvar='somevalue'     #variable assignment
    date +%Y%m%d%H%M%S    #get a formatted date as YYYYMMDDHHMMSS
    wc                    #count words or lines etc. use -l for lines
    tail -f               #print tail updates from file in real time
    gunzip -c             #send gunzipped file content to stdout (keep original file)
    
    mkdir -p foo/bar/baz  #make directory and any intermediate directories if they do not exist
    
Navigate to the previous diectory (go back)

    cd -
    
Show command history

    history
    
    history -w /dev/stdout            #print to stdout, which also excludes those pesky row numbers so you can copy multiple commands at once
    
## Data formatting and delimeter separated files
https://astrobiomike.github.io/unix/six-glorious-commands

Format text output in ordered columns as a table

    column -t
    cat myfile.has.columns | column -t     #example

Select rows with grep and egrep

    gunzip -c combined.hm3_1kg.snplist.vanilla.jz2020.gz | egrep -i '^\w+\s23'


## Multiple commands

Execute commands inline as part of string concatenation
    
    echo "My program output: $(pwd)$(date +%Y%m%d)"
    echo "My program output:" "$(pwd)" "$(date +%Y%m%d)"

Execute each command regardless of the success of the previous:
    
    pwd; cat myfile.md; ls;
    
    pwd || cat myfile.md || ls

Execute each command, but halt at any error:
    
    pwd && cat myfile.md && ls
    
Loop through different values accessed with a variable
    
    for v in a b c d; do echo $v; done
    
Advanced iteration from the command line with awk (and pipe)

    echo $PATH | awk 'BEGIN{RS=":"} {NR": "$0}'

## Redirect all screen output to a file (overwrite)
    
    ls > myOutput.txt

## Redirect all screen output to a file (append)
    
    ls >> myOutput.txt

## Jobs

Background execution. Add & at the end of a command to run the command in the background rather than occupying the terminal. For example:
    
    sh my_script.sh &

List jobs, with info:
    
    jobs -l
    
Abort current (foreground) job:
    
    Ctrl-C

Bring current job to background:

    Ctrl-Z            #also suspends the job - let it continue using bg
    bg #[JOBNUMBER]    #use %?

Bring job to foreground:
    
    fg #[JOBNUMBER]

Kill job in background:
    
    kill %[JOBNUMBER]

List processes:

    ps
    
    ps | grep ssh
    
Kill process

    kill [PROCESSNUMBER]
    
Kill all processes of type ssh:

    pkill ssh

## Links

Create symlink (soft link):
    
    ln -s /scratch/users/kXXXXXXXX/project/ project
    
## File permissions

Set(+,-,=) file permissions (r - read, w - write, x - execute) recursively (-R) on specified directory
for (a - all, u - user, g - group, o - other).

    chmod -R g+rw .   #current folder, group can rw - this is probably what you want in a collaborative environment, or maybe read for the group
    chmod -R a+rw .   #current folder, everyome can rw
    
Set file owner of individual:group as (use -R for recursive actions). Beware of the behavior regarding symbolic links.

    chown postgres:postgres myfile.conf
    
Set group owner only (current folder . , recursively with -R)
    
    chgrp -R er_prj_gwas_sumstats .

## Running scripts and programs

Execute R commands from the command line
    
    R -e 'install.packages(devtools); getwd();'

Run R interactively
    
    R

Execute an R-script
    
    Rscript myproject/myprojectCode.R
    
## Transferring files between machines, and downloading from remote locations

Copy large sets of files locally, the whole folder

    rsync -avhtp --progress /loc1/myfolderSource /loc2/
    rsync -avhtp --progress /loc1/myfolderSource /loc2/myfolderDestination
    rsync -avhtpu --progress /loc1/myfolderSource /loc2/myfolderDestination       #update based on timestamp

Copy file from local machine to remote (Create)
    
    rsync -avzht --progress /Users/myname/myfile.txt hpc.create.kcl.ac.uk:/users/kXXXXXXXX/myfile.txt
    
multiple files from remote to local machine (current folder)

    rsync -avzht --progress 'hpc.create.kcl.ac.uk:/users/kXXXXXXXX/myfile.txt /users/kXXXXXXXX/myfile2.txt' ./

the whole content of a folder (not including the folder) - remove source trailing slash to copy the whole folder
Ref: https://serverfault.com/questions/815688/rsync-compress-level-which-compression-levels-can-be-used/1089914#1089914

    rsync -avzht --compress-choice=lz4 --progress /Users/myname/myfolder/ hpc.create.kcl.ac.uk:/users/kXXXXXXXX/

Downloading file over shaky connections (resumes where it left of if interrupted, makes two tries), specifying the target file (remove the last argument to keep original name)

    wget -c -t 2 http://remote.location/sub/libgit2-devel-0.26.6-1.el7.x86_64.rpm --no-check-certificate -O NEWFILENAME.file

Downloading the content of a whole folder using wget: r - recursive, E - add extensions to known file type streams, x - create the new directories, k - convert remote links to local, p - get required files, erobots=off - do not use robots.txt, np - do not recurse into parent directory

    wget -r –level=0 -E –ignore-length -x -k -p -erobots=off -np -N http://www.remote.com/remote/presentation/dir

## Finding stuff

Find any file in real time prefixed 'setup' in any subfolder to the specified folder (current folder is the default)


    find project/MYPROJECT/ -name setup*    #case sensitive
    find project/MYPROJECT/ -iname setup*   #case insensitive
    
Last - find some really important file on the server in the background (&), do not show the error messages (2>&- alternate 2>/dev/null), save the (std)output to a file, do not use unnecessary resources (nice).
    
    nice find / -name libgit2.pc 1>paths_libgit2.txt 2>&- &
    
## Multitasking with tmux

https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/
https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/

List commands

    Ctrl-b [release] ?

Split screen

    Ctrl-b [release] %                        #split horizontally (vertical line)
    Ctrl-b [release] "                        #split vertically (horizontal line)
    Ctrl-b [release] [arrow]                  #navigate split panes
    exit                                      #close
    Ctrl-d                                    #close
    Ctrl-b [release] z                        #toggle pane full screen
    Ctrl-b [release] Ctrl<arrow key>          #resize pane in direction
    
    
Sessions

    tmux ls                               #list
    Ctrl-b [relese] d                     #detach
    tmux attach -t 0                      #attach
    tmux new -s database                  #new named session
    tmux rename-session -t 0 database     #rename session

# HPC related

## Computer resources

List disk usage of current folder (one sublevel) content with human readable size formats

    du -h -d 1


## Modules (on Create)

List available modules

    module avail
    module spider
    module keyword harfbuzz dev

Add the R-module:
    
    module add apps/R/3.6.0

## Scheduled jobs with the Slurm scheduler
When you log in to Rosalind you start off on a login node. Use other nodes for work.

Start an interactive node.
If multiple partitions possible, separate these with a comma.
    
    srun -p cpu --pty /bin/bash                                          #without specifying resources
    srun -p cpu --ntasks 1 --cpus-per-task 4 --mem 16G --pty /bin/bash   #specifying resources
    srun -p cpu -w noded08 --pty /bin/bash   #specifying node

Exit your interactive node
    
    exit

Submit a command to the Slurm job scheduler
Example - Uses whichever of the brc partition (more resources than the shared) and the shared, settings for a number of tasks, cpu's, memory, and job outpt files, and names output with the current date:
    
    sbatch --time 00:59:00 --partition cpu --job-name="MY_JOB" --ntasks 1 --cpus-per-task 4 --mem-per-cpu 6G --wrap="module add apps/R/3.6.0 && Rscript myprojectCode.R" --output "myprojectCode$(date +%Y%m%d).out.txt" --error "myprojectCode$(date +%Y%m%d).err.txt"

List all Slurm jobs on the HPC
    
    squeue

List user's Slurm job on the HPC
    
    squeue -u kXXXXXXXX

Cancel Slurm job (includes your interactive node)
    
    scancel [JOBID]


## Create HPC custom tool for monitoring disk usage

Load the module and use the tool

    module load utilities/rosalind-fs-quota
    ros-fs-quota
    
## Libraries on the HPC

List and find specific library

    rpm -qa
    rpm -qa | postgres

# Version control and project folder structure with Git

For contributing to an existing GitHub project, see: https://www.dataschool.io/how-to-contribute-on-github/

Common git commands

    git status          #get information on the modification state of the files of the current branch
    git branch          #manage local branches, use -v for verbose info and -r for listing remote branches
    git remote          #manage remote branches, use -v for verbose info
    git checkout        #switch branch, affecting local files, or create new branch immediately and switching to it with -b
    git log             #view commit history, git log --graph --oneline --all for a more graphical representation (compact and showing all branches)
    
    git rebase          #rebase current branch on target branch (incorporating changes from target)
    git merge           #merge changes from target branch on top of current
    git fetch           #get updates from remote branch/repository
    git pull            #fetch and integrate with remote branch/repository (either merge or rebase with --rebase)
    git pull upstream master --rebase   #fetch latest from upstream master and rebase this branch ontop
    git stash           #stash uncommitted changes in local working copy
    git stash pop       #apply top stashed changes on current local working copy, and remove stash. Use apply if you want to retain the stash.
    
Remove/move files/folders, tracked

    git rm -r scripts/archive
    
    git mv scripts/archive scripts/archive2

Remove files, tracked from index without deleting theme (--cached)

    git rm -r --cached scripts/archive

Merge and choosing only the result (ours/theirs) of one branch over the other

    git merge -X ours origin    #choose the content of the current branch  -did not work when I tried it
    git push origin master:master --force   #completely replace remote branch (master), forcefully
https://stackoverflow.com/questions/30464995/move-remote-branch-tip-from-one-branch-to-another

Managing local working copy

    git checkout .                                #Revert local working copy changes to HEAD content
    git checkout upstream/master R/oldcode.R      #Replace local specific file with version from specified repository/branch
    
Viewing remote file content

    git show 656e371e7f9e979d24419acde4738656f8f0d788:scripts/cleaning/sumstats_cleaning.Rmd > scripts/cleaning/sumstats_cleaning2.Rmd

Clone your repository from GitHub or other remote repository into current folder (will create a folder for the cloned project)
  
    git clone https://github.kcl.ac.uk/kXXXXXXXX/myprojectongithub.git

Manage repository remote branches for push and pull, adding origin and an upstream remote branch 

    git remote remove origin
    git remote add origin URL_OF_FORK
    git remote add upstream URL_OF_PROJECT
    
Editing local branch default remote branch

    git branch --unset-upstream                       #remove linked remote branch
    git push origin --set-upstream mynewbranch        #push to origin and link newly created local branch to new remote branch
    
Reset credentials for remote when they have expired

    git config --global --unset user.password
    
Initiate new repository without remote in the current folder (1) or in the specified folder (2). For naming see: https://stackoverflow.com/questions/11947587/is-there-a-naming-convention-for-git-repositories
=> use lower case and hyphens rather than camel case or underscores.

    git init
    git init my-new-rlang-project
    
Initiate new bare repository - convenient to use as a remote repository. Is conventionally appended with the suffix .git (compare with GitHub for example)

    git init --bare my-new-rlang-project.git
    
Looking at changes across commits

    git diff main                 #see changes as compared to the main branch
    git diff main --summary       #as above but only show the affected files and their changes
    
    git difftool main scripts/traits/HEXACO.Rmd     #use configured difftool/editor. configure your .gitconfig with [diff] tool = vimdiff, for example
    
    git mergetool scripts/traits/HEXACO.Rmd     #use configured mergetool/editor. configure your .gitconfig with [merge] tool = vimdiff, for example
    
# Vim

Check out online summary sheets and tutorials such as https://vimsheet.com/
    
Essentials

    :q          #quit Vim
    :w          #save file
    :wq         #save and quit
    y           # 'yank' - copy text within Vim
    c           # 'change (or maybe cut)' - cut text within Vim
    p           # 'paste' - paste text within Vim
    Ctrl-v      #paste into Vim from outside clipboard (works on my MacOS)
    :w !pbcopy  #copy content selected with the visual mode (use the mouse or press v or V) to the outside clipboard
    
    u           #Undo
    Ctrl-r      #Redo
    
    v           #visual mode for marking text - use navigation to control the selection
    
Navigation
    
    Ctrl-e      #scroll up
    Command-<up>  #works on MacOS
    Ctrl-y      #scroll down
    Command-<down>  #works on MacOS
    
    H           #higher part of the screen
    M           #middle part of the screen
    L           #lower part of the screen

    ^           #beginning of a line
    $           #end of line
    w           #beginning of next word
    W
    e           #end of next word
    E
    b           #back one word (beginning?)
    B
    }           #forward to the next paragraph
    {           #back to the last paragraph
    
    42gg        #line 42
    42G
    :42<CR>
    
Search

    /pattern    #search for pattern, forward
    ?pattern    #search for pattern, backward
    n           #repeat search, same direction
    N           #repeat search, opposite direction
    f [char]    #move to character, forward
    F [char]    #move to character, backward
    
Diff and split

    :vs otherFile       #vertical split and open other file
    :split otherFile    #horisontal split and open other file
    ctrl+w ctrl+w       #change cursor between diffs
    :diffthis           #diff with this file
    :diffoff            #turn off diff
    ctrl+w+q            #close split windows one at a time
    :on                 #on(ly) display the current split window
    
# Python (for python 3)

Create a virtual environment called 'myvenv'

    python3 -m venv myvenv
    virtualenv --python=python2.7 myenv #if you need a python2.7 environment
    
Activate and deactivate virtual environment

    source myvenv/bin/activate

    deactivate
    
List packages/modules (outdated)

    pip list --outdated
    
Install specific module
You can upgrade pip this way also as it is a module

    python3 -m pip install SomePackage
    
    pip install SomePackage
    
    pip install bitarray --force-reinstall #upgrade even if package exists
    
    pip install 'bitarray>=0.8,<0.9' --force-reinstall #possibly downgrade
    
    pip install --upgrade pip
    
Install requirements with pip using a requirements file 

    python3 -m pip install -r requirements.txt
    
Produce a pip requirements file from the current installation

    python3 -m pip freeze
    