# Tailscale Management Plane

## 1. Purpose

This document defines the policy governing the Tailscale network used to administer Alex-controlled infrastructure and provide private network reachability to Money Ex Machina infrastructure.

Tailscale forms the private infrastructure management plane.

Its role is to provide:

- authenticated private network membership;
- machine and service network identity;
- controlled network reachability between security domains;
- a stable private transport for infrastructure administration.

Tailscale is not the application security authority for MXM.

In particular:

```text
network reachability
        ≠
host authentication
        ≠
application authentication
        ≠
authorization
        ≠
capability
```

Ordinary host administration continues to use OpenSSH and Alex's hardware-backed SSH credentials.

MXM application and workload authority is provided separately through the MXM security architecture and OpenBao.

---

## 2. Security-domain placement

The Tailscale management plane belongs to the Alex security and infrastructure domain.

It sits above the MXM security and autonomous-workload domains and provides controlled connectivity into them.

```text
Alex Security / Infrastructure Domain
        │
        ├── Tailscale governance
        ├── human Tailscale identity
        ├── Forge
        ├── Monolith
        └── infrastructure bootstrap authority
                │
                ▼
        private management plane
                │
        ┌───────┴────────┐
        ▼                ▼
MXM Security        MXM Autonomous
Domain              Workload Domain
        │                │
        ▼                ▼
mxm-security        mxm-factory-agent
```

MXM machines participate in the tailnet as distinct service identities.

They do not inherit Alex's human identity merely by joining the same private network.

---

## 3. Tailnet governance

The tailnet is currently owned by the Tailscale user authenticated through:

```text
moneyexmachina@github
```

This user holds the Tailscale `Owner` role.

The Owner is the ultimate human governance authority for:

```text
tailnet membership
tailnet policy
service tags
tag ownership
OAuth clients
authentication keys
DNS and network configuration
administrative roles
```

Human tailnet governance remains part of the Alex security domain.

MXM infrastructure must not acquire general tailnet-administration authority.

A separate recovery/admin authentication path should exist so that loss of the primary GitHub identity alone does not imply loss of tailnet governance.

---

## 4. Identity model

The management plane distinguishes between **user-owned devices** and **tag-owned service devices**.

### User-owned infrastructure

Forge and Monolith are currently ordinary Tailscale devices owned by the tailnet Owner:

```text
moneyexmachina@github
        │
        ├── forge
        └── monolith
```

These machines remain user-owned.

They are not assigned an artificial `alex` or infrastructure tag merely to express their ownership.

The governing abstraction is:

```text
Owner-owned device
```

rather than:

```text
device carrying an Alex tag
```

Any future device deliberately authenticated as the same Owner identity belongs to the same user-owned management domain unless policy is deliberately changed.

### Service-owned MXM infrastructure

Non-human MXM infrastructure receives tag-based service identities.

Initial service identities are:

```text
tag:mxm-security
tag:mxm-factory-agent
```

A tagged MXM device represents its service role rather than Alex's human identity.

Applying an MXM service tag is therefore a security lifecycle operation, not merely descriptive labelling.

---

## 5. Provisioning identity

Automated MXM infrastructure construction requires authority to create new tagged Tailscale nodes.

A dedicated provisioning identity is used:

```text
tag:mxm-bootstrap
```

Its purpose is narrowly bounded:

```text
tag:mxm-bootstrap
        │
        ├── may provision tag:mxm-security
        └── may provision tag:mxm-factory-agent
```

The provisioning identity does not represent a running MXM workload.

It represents the authority used by trusted infrastructure automation to create approved MXM network identities.

The durable provisioning credential belongs to the trusted bootstrap environment on Forge.

It must not grant general Tailscale administration.

---

## 6. Network-access policy

The tailnet is governed by least-privilege, deny-by-default connectivity.

The initial required relationships are:

```text
Owner-owned devices
        ↔
Owner-owned devices
        unrestricted private connectivity

Owner-owned devices
        │
        ├── TCP/22 ──> tag:mxm-security
        │
        └── TCP/22 ──> tag:mxm-factory-agent

tag:mxm-security
        ──> no independently granted connectivity

tag:mxm-factory-agent
        ──> no independently granted connectivity
```

Therefore:

```text
forge ↔ monolith
```

continues to work as trusted Alex-domain infrastructure communication.

Alex can administer either MXM VM over ordinary OpenSSH.

The MXM security VM and autonomous factory agent do not gain lateral access merely because they belong to the same tailnet.

Any future machine-to-machine relationship must be introduced explicitly.

For example, eventual factory-agent access to OpenBao would require a deliberate network grant in addition to the separate transport-security, authentication and OpenBao-authorization mechanisms required by the MXM security policy.

---

## 7. Host authentication

Tailscale provides private network reachability.

It does not replace host authentication.

Administrative SSH follows:

```text
Alex-controlled device
        ↓
Tailscale private transport
        ↓
MXM or Alex infrastructure host
        ↓
OpenSSH
        ↓
Alex hardware-backed SSH credential
```

Tailscale SSH is not part of the management-plane architecture.

Tailscale clients should therefore not enable Tailscale SSH unless this policy is deliberately changed.

---

## 8. Declarative policy

The authoritative tailnet access policy is maintained as source-controlled configuration in the Alex infrastructure configuration managed through chezmoi.

Current location:

```text
~/.tailscale-management/
├── README.md
└── policy.hujson
```

`README.md` defines the governing architecture and security policy.

`policy.hujson` is the executable Tailscale tailnet policy.

The source-controlled policy must include tests for important security invariants before it becomes the operational source of truth.

The tailnet policy belongs to the Alex security/infrastructure domain.

It must not be controlled by `mxm-infra`.

The dependency direction is:

```text
Alex Tailscale management plane
        │
        │ defines service identities and connectivity
        ▼
MXM infrastructure provisioning interface
        │
        │ consumed by
        ▼
mxm-infra
```

not:

```text
mxm-infra
        ↓
general authority over Alex's tailnet
```

---

## 9. MXM Layer-0 infrastructure construction

The management plane must support fully automated MXM appliance construction.

The target operator interface is:

```text
alex@forge
        ↓
make plan STACK=<stack>
make apply STACK=<stack>
        ↓
complete reachable appliance
```

Layer-0 construction must not require:

```text
looking up the operator's current public IP
opening temporary public SSH access
interactive Tailscale login on the new VM
manual package installation
manual machine tagging
manual host configuration
```

Forge holds narrowly scoped bootstrap credentials in gopass.

For Tailscale this consists of a dedicated OAuth client capable of deriving enrollment authority for approved MXM service identities.

The expected construction flow is:

```text
alex@forge
        ↓
gopass
        ↓
narrow Tailscale provisioning OAuth credential
        ↓
derive disposable enrollment authority
        ↓
construct VM
        ↓
VM joins tailnet as approved service identity
        ↓
disposable enrollment authority expires or is consumed
        ↓
private management path operational
```

The durable OAuth credential must remain on the trusted bootstrap side.

It must not become a standing credential on the provisioned MXM VM.

---

## 10. Credential separation

The management plane distinguishes between several classes of authority.

```text
Tailnet Owner authority
    ultimate human governance
    Alex security domain

Tailnet recovery/admin authority
    independent recovery of human administration
    Alex security domain

MXM provisioning OAuth authority
    derives approved service-node enrollment authority
    Forge bootstrap environment

Disposable enrollment authority
    used to enroll one newly created MXM appliance
    transient

MXM service identity
    persistent identity of the resulting Tailscale node
    provisioned appliance
```

These authorities must not be collapsed into one universal credential.

In particular, compromise of the Forge MXM provisioning credential must not imply general tailnet-administration authority.

---

## 11. Relationship with OpenBao

Tailscale and OpenBao solve different security problems.

Tailscale establishes controlled private network reachability.

OpenBao establishes MXM security identity, authorization and derived capability.

For example:

```text
factory agent
        ↓
Tailscale network permission
        ↓
can reach OpenBao endpoint
```

would establish only network reachability.

The workload must still separately satisfy:

```text
encrypted authenticated transport
server identity verification
OpenBao workload authentication
OpenBao authorization policy
requested capability policy
```

No Tailscale tag alone grants OpenBao authority.

---

## 12. Recovery model

Loss of an MXM VM does not require recovery of its old Tailscale node identity.

A reconstructed VM receives a new infrastructure/network identity carrying the same approved service role.

For example:

```text
destroy mxm-security VM
        ↓
old Tailscale node disappears
        ↓
mxm-infra reconstructs fresh appliance
        ↓
fresh node joins as tag:mxm-security
        ↓
management connectivity restored
```

The logical OpenBao security authority is recovered separately from its Raft snapshot and external Shamir authority.

Thus:

```text
Tailscale node identity
        ≠
OpenBao logical security authority
```

Loss of Forge must likewise not imply loss of tailnet governance.

Alex retains the human authority required to revoke or recreate MXM provisioning credentials and bootstrap a replacement trusted infrastructure environment.

---

## 13. Current baseline

At initial policy formalisation, the tailnet contains:

```text
forge
    user-owned by moneyexmachina@github
    Tailscale SSH disabled

monolith
    user-owned by moneyexmachina@github
```

No MXM service-tagged cloud VMs currently participate in the tailnet.

The captured initial `policy.hujson` is the standard permissive Tailscale template containing:

```text
* → * : all IP connectivity allowed
```

This baseline was captured in source control before policy redesign.

The permissive wildcard grant is temporary and will be replaced by explicit Grants implementing this document.

---

## 14. Core invariants

1. The tailnet management plane belongs to the Alex security/infrastructure domain.

2. Forge and Monolith remain user-owned infrastructure rather than receiving artificial service tags.

3. MXM cloud appliances use tag-based service identities and do not inherit Alex's human identity.

4. User-owned Owner devices may communicate freely with the Owner's other devices.

5. Owner-owned devices may administer MXM infrastructure over TCP/22.

6. MXM service identities receive no lateral connectivity unless explicitly granted.

7. Tailscale provides network reachability; OpenSSH remains the normal administrative host-authentication mechanism.

8. Tailscale SSH is not enabled.

9. The general tailnet policy is not governed by `mxm-infra`.

10. Forge receives only the bounded authority required to provision approved MXM service identities.

11. MXM node enrollment must be automated as part of Layer-0 appliance construction.

12. Routine MXM infrastructure construction must not depend on the operator's current public IP address.

13. Tailnet governance must remain recoverable independently of Forge and independently of MXM.

14. Network membership or reachability alone never implies application authority.
