# squadra
Automated BostonHacks Team Onboarding

## Joining 

Part of the team? Fork this repo, edit `team.yml` to add yourself, and make a pull request.

## Developing

Be. Very. Careful. You can accidentally remove all of us from the github org, and then we are royally fucked. Do NOT set the PROD env var to true unless this is the production deployment on circle. When adding new services, you should wrap all non-idempotent calls (POST/PUT/DELETE) in ENV['PROD'] guards to prevent accidental modification of live credentials during testing/dev. If that sentence didn't make any sense, NO TOUCHING
