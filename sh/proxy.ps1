# Set proxy environment variables
$http_proxy=$args[0]
$https_proxy=$http_proxy
Set-Item -Path Env:http_proxy -Value $http_proxy
Set-Item -Path Env:HTTP_PROXY -Value $http_proxy
Set-Item -Path Env:https_proxy -Value $http_proxy
Set-Item -Path Env:HTTPS_PROXY -Value $https_proxy
$no_proxy="127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.internal"
# Don't use proxy for "internal" domain, e.g. kubernetes.docker.internal, minikube.internal, etc.
Set-Item -Path Env:no_proxy -Value $no_proxy
Set-Item -Path Env:NO_PROXY -Value $no_proxy
Set-Item -Path Env:VAGRANT_HTTP_PROXY -Value $http_proxy
Set-Item -Path Env:VAGRANT_HTTPS_PROXY -Value $https_proxy
Set-Item -Path Env:VAGRANT_NO_PROXY -Value $no_proxy
