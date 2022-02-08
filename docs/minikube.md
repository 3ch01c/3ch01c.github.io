# Minikube

<a name="start"></a>
Start a cluster with 8 CPUs, 8 GB memory using Virtualbox.

```sh
minikube start --cpus 8 --memory 8192 --driver virtualbox
```

## Set up Docker environment variables.

You'll need this to set the parameters to be able to connect to the Docker daemon.

On Linux, run this command:

```sh
. minikube docker-env
```

On Windows, run this command:

```sh
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

## Troubleshooting

Virtualbox seems to be the most environment-agnostic way to run Minikube so adding the `--driver virtualbox` flag is recommended. Make sure to install Virtualbox extensions, and restart your computer after you install Virtualbox. If Minikube complains about not having VT-x extensions installed and you're sure you have them enabled in BIOS, add the `--no-vtx-check` flag. The default 192.168.59.1/24 CIDR was conflicting with my network so I forced `--host-only-cidr 10.0.0.1/24`.

```sh
minikube start --driver virtualbox --no-vtx-check --host-only-cidr 10.0.0.1/24
```