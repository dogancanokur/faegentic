# Unreal rules

Writers follow these rules. Reviewers check against them.

## Architecture

- Follow Unreal Engine coding standards and the existing project architecture.
- No unnecessary abstractions, refactors, or speculative APIs.
- C++ owns reusable systems, state integrity, validation, low-level logic, and replication rules.
- Blueprint owns gameplay orchestration, sequencing, system wiring, animation, sound, VFX, and designer-driven behavior.
- Expose to Blueprint only: gameplay actions, read-only queries, meaningful events/delegates, designer-tunable properties. Never internal implementation details.
- If the project has test infrastructure and the change is testable, add tests. Otherwise do not create test infrastructure; list Editor or PIE validation steps in the report.
- Comment only when intent or Unreal-specific behavior is not obvious from the code.

## Section banners

Group C++ declarations and definitions under section banners. Exact format, indented to the code it groups:

```cpp
	// ------------------------------------------------------------------
	// <Section name>
	// ------------------------------------------------------------------
```

Section names, in this order. Use only sections that have content:

| Section | Holds |
| --- | --- |
| `Lifecycle` | Constructor, `BeginPlay`, `Tick`, `EndPlay`, other engine lifecycle overrides |
| `<ParentClass> Overrides` | Other virtual overrides of the parent, e.g. `AActor Overrides` |
| `<IInterface> Implementation` | One section per implemented interface, e.g. `IInteractable Implementation` |
| `Gameplay Actions` | `BlueprintCallable` actions |
| `Queries` | `BlueprintPure` / const getters |
| `Events` | Delegate declarations and `BlueprintImplementableEvent` / `BlueprintNativeEvent` |
| `Replication` | `GetLifetimeReplicatedProps`, `OnRep_` functions, RPCs |
| `Internal` | Private helpers |
| `Variables & Components` | `UPROPERTY` members and components |

Header example:

```cpp
UCLASS()
class MYGAME_API ADoor : public AActor, public IInteractable
{
	GENERATED_BODY()

public:
	// ------------------------------------------------------------------
	// Lifecycle
	// ------------------------------------------------------------------
	ADoor();
	virtual void BeginPlay() override;

	// ------------------------------------------------------------------
	// IInteractable Implementation
	// ------------------------------------------------------------------
	virtual void Interact_Implementation(AActor* InstigatorActor) override;

	// ------------------------------------------------------------------
	// Queries
	// ------------------------------------------------------------------
	UFUNCTION(BlueprintPure, Category = "Door")
	bool IsOpen() const { return bIsOpen; }

private:
	// ------------------------------------------------------------------
	// Variables & Components
	// ------------------------------------------------------------------
	UPROPERTY(VisibleAnywhere, Category = "Door")
	TObjectPtr<UStaticMeshComponent> DoorMesh;

	UPROPERTY(EditAnywhere, Category = "Door")
	bool bIsOpen = false;
};
```

In the `.cpp`, use the same banners in the same order, at column 0, around the matching definitions.

Existing files: if a file already uses banners, put new code in the matching section. If it has none, put only your new code under banners. Do not regroup existing code.
