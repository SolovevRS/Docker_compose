FROM jetbrains/teamcity-agent:2023.05.1

# Switch to the root user to install software
USER root



# This is the corrected version for your Dockerfile

RUN \
    # 1. CRITICAL STEP: Remove the old, broken perforce.list file from the base image.
    rm -f /etc/apt/sources.list.d/perforce.list && \
    \
    # 2. Now run update and install the tools we need. This will now succeed.
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg && \
    \
    # 3. Add the new, valid Perforce GPG key.
    curl -fsSL https://package.perforce.com/perforce.pubkey | gpg --dearmor -o /usr/share/keyrings/perforce.gpg && \
    \
    # 4. Add the new, correct repository source file, pointing to the key we just added.
    echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] https://package.perforce.com/apt/ubuntu focal release" > /etc/apt/sources.list.d/perforce.list && \
    \
    # 5. Run update again to fetch the package list from the new Perforce repo.
    apt-get update && \
    \
    # 6. Install your final list of desired packages.
    apt-get install -y \
        wget \
        sudo \
        python3 \
        python3-pip && \
    \
    # 7. Clean up to keep the image size down.
    rm -rf /var/lib/apt/lists/*


# FIX: Add the valid GPG key for the Perforce repository to prevent apt-get errors
#RUN wget -qO - https://package.perforce.com/perforce.pub | apt-key add -



# Use pip to install Ansible
RUN pip3 install ansible

# Optional but recommended: Add the buildagent user to the sudoers file
RUN echo "buildagent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch back to the default non-root user for security
USER buildagent
