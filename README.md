# Simple video streaming service

This service creates a two container pod, one generating an HLS stream to a shared volume using gstreamer with a configurable source.  The second creates a simple nginx server that has an html5 video player that will display the stream.

The purpose of this project is to showcase orchestrating a service that uses container composition to create a functioning application that makes use of a physical device such as ```/dev/video0``` on the host.

## Smarter-device-manager

As this project needs access to a physical device, we need to make use of the k8s [device plugin](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) to expose these capabailities in a managed way to the containers.  For this, we make use of the [smarter-device-manager](https://community.arm.com/developer/research/b/articles/posts/a-smarter-device-manager-for-kubernetes-on-the-edge) orginally from Arm Research.

```bash
# Deploy the device manager service
kubectl apply -f device_manager/device-manager.yaml

# Enable the device manager service
# replace <node_name> with the name of your k3s node the service is deployed to
kubectl label node <node_name> smarter-device-manager=enabled

```

The default configuration here only exposes ```/dev/video[0-9]``` , if you need different devices exposed the modify the ConfigMap contained in the device-manager.yaml file.

Once the smarter-devices service has been deployed, you can inspect the available devices

```bash
# Again, replace <node_name> with the name of your node
kubectl describe node <node_name>
```

The output of this should show something like

```yaml
#<snip>
Capacity:
  smarter-devices/video0:    10
  smarter-devices/video2:    10
```

Which in this instance shows that I have two video devices available that have the capacity to be shared with up to 10 containers.

## Deploying the service

To deploy the video service, first make sure that the service definition in ```video_stream/service.yaml``` is requesting access to the correct ```smarter-devices/video``` device for your platform.  For example, on my platform I want to expose a webcam that is attached to /dev/video3, so I would have the following in 

```bash
    resources:
      requests:
        smarter-devices/video3: 1
      limits:
        smarter-devices/video3: 1
    # The shared volume for http video is mounted at /live
    # And the video device I want to use is /dev/video3
    args: ["-o", "/live", "-d", "/dev/video3"]
```

Then I can launch the service in the standard way with ```kubectl```.

```bash
kubectl apply -f service.yaml
```

The page should now be available at http://<device-ip>:8080.  If using a modern chrome browser, it will not like connecting to a non-secure webserver, in my configuration everything on my home network resolves to a ```<host name>.localdomain```, so all I need to do is tell chrome to trust anything on my subnet.

## Building

All the containers needed for this project to work are available upstream already, but if you would like to build yourself then use ```build.sh```.  The default configuration is to deploy to my namespace on hub.docker.com, so you will need to change this for your settings.

```bash
PROFILE=`your hub.docker.com profile name` ./build.sh
```

## TODO
- [ ] enable streaming via https to remove the need to alter chromes configuration
- [ ] use a [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) to share configuration between the containers
- [ ] remove the lag in the stream

## Footnote

I am no live streaming expert, this is supposed to be a functional demo, not a production ready solution.  If you have skills in creating a GStreamer pipeline that will server a live stream to an HTML5 compatible browser, please make suggestions to improve the container.