# ADR-001: Use Docker Compose + Doco-CD to Preserve Native TOS Storage (With Planned Talos K8s Evolution)

* **Status:** Accepted
* **Deciders:** Karthikeyan Karuppiah

## Context and Problem Statement
The infrastructure runs on a TerraMaster NAS (TNAS) appliance powered by TerraMaster Operating System (TOS). Because TOS provides hardware-tuned RAID management, SMART disk health monitoring, and native filesystem services out of the box, wiping the appliance OS solely to run an immutable Kubernetes OS (such as Talos Linux) would sacrifice turnkey NAS storage management. We needed a declarative, pull-based GitOps deployment model that runs natively on top of TOS today while keeping workloads portable for a future migration to Talos Linux and Kubernetes.

## Decision Drivers
* **Preserve Native TOS Storage Appliance Capabilities:** Retain TOS for hardware RAID, disk health alerting, and storage pool stability without virtualizing storage controllers.
* **True Pull-Based GitOps Reconciliation:** Achieve automated drift reconciliation from `main` without exposing SSH or Docker sockets to external CI runners.
* **Resource Efficiency on Single-Node Hardware:** Avoid running a full Kubernetes control plane (`etcd`, `kube-apiserver`) on top of an existing NAS OS.
* **Future Portability to Talos Linux:** Keep application configurations, SOPS-encrypted secrets, and container digest pinning decoupled from the host OS so workloads can cleanly migrate to a dedicated Talos Kubernetes cluster later.

## Considered Options
1. **Preserve TOS + Docker Compose + Doco-CD (Current Phase)**
2. **Bare-Metal Talos Linux + Kubernetes + FluxCD / ArgoCD (Evaluated for Next Phase)**
3. **Run Talos Linux inside a Virtual Machine on TOS**

## Decision Outcome
**Chosen option: "Preserve TOS + Docker Compose + Doco-CD"**, because it protects native NAS storage reliability while delivering full GitOps automation (`Doco-CD`), CIS security linting (`compose-lint`), and supply-chain verification (`Trivy` + `Renovate`) with near-zero runtime overhead. **Talos Linux + Kubernetes** remains on the architectural roadmap as the target platform once dedicated compute nodes are introduced or storage and compute planes are separated.

### Positive Consequences
* **Turnkey Storage Reliability:** Keeps TerraMaster's native RAID, power management, and storage monitoring intact without nested virtualization overhead.
* **Enterprise DevSecOps Parity:** Delivers pull-based GitOps reconciliation, SOPS secret encryption, and automated SHA256 digest rollouts comparable to FluxCD/ArgoCD.
* **Clean Migration Path to Talos:** Stateless containers, externalized `/Volume1/DockerAppsData/` volumes, and SOPS-encrypted `.env` files map directly to Kubernetes Deployments, PersistentVolumes, and SOPS-operator secrets when transitioning to Talos.

### Negative Consequences
* **Single-Node Boundary:** Workloads remain tied to the TNAS host until compute is decoupled onto Talos Linux nodes.
* **No Native Kubernetes Primitives Yet:** Lacks declarative CRDs, NetworkPolicies, and multi-node pod rescheduling until the Talos migration phase is executed.
