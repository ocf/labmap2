from pathlib import Path

from transpire.resources import Deployment, Ingress, Secret, Service
from transpire.types import Image
from transpire.utils import get_image_tag, get_revision

name = "labmap2"
auto_sync = True


def images():
    yield Image(name="backend", path=Path("/backend/data_generator_server/"), registry="ghcr")
    yield Image(name="frontend", path=Path("/frontend/labmap2_server/"), registry="ghcr")


def add_labmap_common(dep):
    dep.obj.spec.template.spec.dns_policy = "ClusterFirst"
    dep.obj.spec.template.spec.dns_config = {"searches": ["ocf.berkeley.edu"]}

def add_probes(dep, path="/health"):
    dep.obj.spec.template.spec.containers[0].readiness_probe = {
        "httpGet": {
            "path": path,
            "port": 8080,
        },
        "initialDelaySeconds": 5,
        "periodSeconds": 5,
    }

    dep.obj.spec.template.spec.containers[0].liveness_probe = {
        "httpGet": {
            "path": path,
            "port": 8080,
        },
        "initialDelaySeconds": 10,
        "timeoutSeconds": 3,
        "failureThreshold": 6,
    }


def objects():
    yield Secret(
        name="labmap2",
        string_data={
            "PROMETHEUS_PASSWORD": "",
        },
    ).build()

    dep_backend = Deployment(
        name="labmap-backend",
        image=get_image_tag("backend"),
        ports=[8080],
    )
    add_labmap_common(dep_backend)
    add_probes(dep_backend)
    dep_backend.pod_spec().with_secret_env("labmap2")
    yield dep_backend.build()

    dep_frontend = Deployment(
        name="labmap-frontend",
        image=get_image_tag("frontend"),
        ports=[8080],
    )
    add_labmap_common(dep_frontend)
    yield dep_frontend.build()

    svc_backend = Service(
        name="labmap2-backend",
        selector=dep_backend.get_selector(),
        port_on_pod=8080,
        port_on_svc=80,
    )
    yield svc_backend.build()

    svc_frontend = Service(
        name="labmap2-frontend",
        selector=dep_frontend.get_selector(),
        port_on_pod=8080,
        port_on_svc=80,
    )
    yield svc_frontend.build()

    ing_frontend = Ingress.from_svc(
        svc=svc_frontend,
        host="labmap.ocf.berkeley.edu",
        path_prefix="/",
    )
    yield ing_frontend.build()
