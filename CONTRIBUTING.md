# contributing

## colours
- never hard-code colours in screens
- brand: `Theme.of(context).colorScheme.primary`
- warnings: `context.severity.stop` / `.soon` / `.safe` / `.info`

## folders
- each feature lives in `lib/features/<name>/`
- `presentation/` screens, widgets, providers
- `domain/` models
- `data/` firebase or local storage code
- shared stuff goes in `lib/core/`

## git
- branch from `main`: `feat/<name>`, `fix/<name>`
- small commits, lowercase messages: `feat: add login screen`
- run `flutter analyze` and `flutter test` before pushing
- open a pr to `main`, never push to `main` directly

## secrets
- never commit api keys, `.env` files or service account json