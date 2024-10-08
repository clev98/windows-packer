### Connor Notes:
Need to download virtio-win.iso and place in this directory with the name of "virtio-win.iso"
Should place Windows ISOs here depending on what we're building. I use a Win10_EDU_1703 for building Windows 10 images, since it's old enough to not make disabling defender impossible.
virtio-win.iso direct download: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

### What Is This Directory For?

You should download your Windows Server ISO images from TechNet/MSDN and place them in this folder. We need to do this because MSDN / TechNet are protected by Microsoft (Live) ID, which does not support HTTP basic authentication or the OAuth2 username / password flow.

For example, you might want to start with one of the following:

* Windows Server 2008 R2 + SP1: 
	* File Name: en_windows_server_2008_r2_with_sp1_x64_dvd_617601.iso
	* SHA1 Hash: D3FD7BF85EE1D5BDD72DE5B2C69A7B470733CD0A
	* Direct Download: http://msdn.microsoft.com/subscriptions/json/GetDownloadRequest?brand=MSDN&locale=en-us&fileId=44782&activexDisabled=true&akamaiDL=false
* Windows Server 2008 R2 + SP1 (Volume License): 
	* File Name: en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso
	* SHA1 Hash: 7E7E9425041B3328CCF723A0855C2BC4F462EC57
	* Direct Download: http://msdn.microsoft.com/subscriptions/json/GetDownloadRequest?brand=MSDN&locale=en-us&fileId=44783&activexDisabled=true&akamaiDL=false
* Windows Server 2012:
	* File Name: en_windows_server_2012_x64_dvd_915478.iso
	* SHA1 Hash: D09E752B1EE480BC7E93DFA7D5C3A9B8AAC477BA
	* Direct Download: http://msdn.microsoft.com/subscriptions/json/GetDownloadRequest?brand=MSDN&locale=en-us&fileId=50539&activexDisabled=true&akamaiDL=false
* Windows Server 2012 (Volume License):
	* File Name: en_windows_server_2012_vl_x64_dvd_917758.iso
	* SHA1 Hash: 063BC26ED45C50D3745CCAD52DD7B3F3CE13F36D
	* Direct Download: http://msdn.microsoft.com/subscriptions/json/GetDownloadRequest?brand=MSDN&locale=en-us&fileId=50573&activexDisabled=true&akamaiDL=false