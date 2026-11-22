# Contributing

## First-time setup

1. Install Flutter and Android Studio (with an emulator).
2. Clone the repo and open it in VS Code.
3. Run `flutter pub get`.
4. Run `flutter run`.
5. Log in with the dev account you received privately.
6. For Google sign-in: run `cd android && ./gradlew signingReport` and send your debug SHA-1 to the team lead.

## Colours

- Never hard-code colours in screens.
- Brand: `Theme.of(context).colorScheme.primary`
- Warnings: `context.severity.stop` / `.soon` / `.safe` / `.info`

## Folders

- Each feature lives in `lib/features/<name>/`.
  - `presentation/`: screens, widgets, providers
  - `domain/`: models
  - `data/`: Firebase or local storage code
- Shared code goes in `lib/core/`.
- Follow the patterns already in the repo (forms: `login_screen.dart`, Firestore: `user_repository.dart`).

## Shared widgets

Use these instead of building your own. They live in `lib/core/widgets/`.

| Widget                                     | File                  | Use for                                     |
| ------------------------------------------ | --------------------- | ------------------------------------------- |
| `PrimaryButton`, `SecondaryButton`         | `app_button.dart`     | Main and second actions on a screen         |
| `SectionHeader`                            | `section_header.dart` | Small uppercase title above a group         |
| `InfoCard`                                 | `info_card.dart`      | A card with an optional icon and title      |
| `EmptyState`, `LoadingState`, `ErrorState` | `state_views.dart`    | Empty lists, loading and errors             |
| `SeverityBadge`, `SeverityChip`            | `severity_badge.dart` | Showing how serious a warning is            |
| `OfflineBanner`                            | `offline_banner.dart` | Already in the app shell, no need to add it |

Buttons (pass `loading: true` while saving, the button shows a spinner and can't be tapped):

```dart
PrimaryButton(
  label: 'Save vehicle',
  icon: LucideIcons.check,
  loading: _saving,
  onPressed: _save,
)
SecondaryButton(label: 'Cancel', onPressed: () => context.pop())
```

Section header and card:

```dart
SectionHeader('Upcoming', actionLabel: 'See all', onAction: () {})
InfoCard(
  title: 'Next service',
  icon: LucideIcons.wrench,
  onTap: () {},
  child: const Text('In 1,200 km'),
)
```

States, most useful inside `asyncValue.when(...)`:

```dart
items.when(
  loading: () => const LoadingState(message: 'Loading vehicles'),
  error: (_, _) => ErrorState(onRetry: () => ref.invalidate(vehiclesProvider)),
  data: (list) => list.isEmpty
      ? EmptyState(
          icon: LucideIcons.car,
          title: 'No vehicles yet',
          message: 'Add your car to get reminders.',
          actionLabel: 'Add vehicle',
          onAction: () => context.push('/vehicles/add'),
        )
      : VehicleList(list),
)
```

Severity (import `core/theme/severity.dart`, values are `stop`, `soon`, `safe`, `info`):

```dart
const SeverityBadge(severity: Severity.stop, prefix: 'Usually: ')
const SeverityChip(severity: Severity.soon)
```

Offline check, if a screen needs to know:

```dart
final offline = ref.watch(isOfflineProvider).value ?? false;
```

## Git workflow

- `main` is stable and demo-ready. Only `dev` merges into it.
- `dev` is where all work comes together.
- Start every task from `dev`:
  `git checkout dev && git pull && git checkout -b feat/<name>`
- Keep commits small. Messages follow the format `feat: add login screen`.
- Run `flutter analyze` and `flutter test` before pushing.
- Open your pull request into `dev`, never into `main`.
- Merge with **Create a merge commit**. Don't delete branches.

## Secrets

- Never commit API keys, passwords, `.env` files or service account JSON.
- Dev account passwords are shared privately, never in the repo or group chat.
