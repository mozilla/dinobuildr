# Contributing to dinobuildr

Anyone may contribute issues or code to dinobuildr as long as the following guidelines are adhered to.

1) All contributors are expected to follow the Mozilla Community Participation Guidelines outlined at https://www.mozilla.org/en-US/about/governance/policies/participation/

2) Issue naming schema (Recommended):
  * The following are naming conventions already in production. There may also be open issues that do not conform to the schema as well.
    * Bug: [short description of the bug]
    * Documentation: [short description of requested documentation]
    * Feature: [short description of the feature]
    * Update: [short description of the update]
        * Update should be used for changes to existing Documentation, Features, etc
    Please note: other issue types can be created as needed, per the discretion of Mozilla staff maintaining the project

3) Naming branches:
  * Branch names should be written in kebab-case (https://en.wikipedia.org/wiki/Kebab_case) and should and should follow the following pattern:
      * bug-shortbugname
      * doc-shortdocummentname
      * feat-shortfeaturename
      * upd8-shortupdatename
  * Kebab-case helps distinguish between files in the repositories, which are mostly in snake_case (and will primarly transition entirely to snake_case with future commits)
  
4) Commits:
  * Each commit should be small, complete, and isolated to a specific change.
      * In example:
        * If you're updating the link to the DMG installer of a piece of software the changes in the commit should be limited to updating the path for the installer in the appropriate *_manifest.json and the hash for the DMG.
        * A second commit should then be performed to update the hash of the *_manifest.json file in dino_engine.py

5) Pull Requests:
  * Pull requests should reflect a tightly focused group of commits that serve a singular purpose, like updating the files associated with a particular software download, or naming convention change.
      * Pull Request naming should reflect the changes that were made
      * Pull Request comments should explain the changes that were made in the commits that made up the PR
      * Pull Requests must be reviewed by at least one additionl project member, and can only be merged by project admins
