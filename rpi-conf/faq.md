# FAQ

- Disable Swap on Raspberry Pi
```
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo systemctl disable dphys-swapfile
```
