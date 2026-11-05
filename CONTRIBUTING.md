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
