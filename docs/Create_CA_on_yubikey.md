
# Using a yubikey 5 As a root CA 


# make sure you have yubikey software installed
```bash
# First, load the desired key into slot 9c (note you may wish to set a touch-policy and pin-policy of never for embedded devices)
sudo --preserve-env ykman piv keys import 9c /home/william86370/k8s-homelab/pki/lbcloud-pki-root-1/lbcloud-pki-root-1.key --touch-policy=always --pin-policy=ONCE

# Second, load the certificate file into slot 9c
sudo --preserve-env ykman piv certificates import 9c /home/william86370/k8s-homelab/pki/lbcloud-pki-root-1/lbcloud-pki-root-1.pem
 
# Report new device status
sudo --preserve-env ykman piv info
```