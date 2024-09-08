   
   # add an ssh agent to the environment variables
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    # add the key to the agent using sudo to avoid permission issues
    sudo /bin/bash -c "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK ; export SSH_AGENT_PID=$SSH_AGENT_PID; ssh-add -K"
fi