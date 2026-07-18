# CHANGES — bug fixes to the original schema (Jul 2026)

Revisited this coursework project with fresh eyes and fixed five issues.
Kept as a separate `fixes.sql` rather than rewriting history — the bugs and
their fixes are part of the learning.

| # | Issue | Fix | Why it matters |
|---|---|---|---|
| 1 | Archive triggers deleted **every** row with status Completed/Cancelled, not just the rows being updated; two separate AFTER UPDATE triggers on one table | One merged trigger, scoped to the `inserted` set, with a NOT EXISTS guard against double-archiving | Unscoped DML in triggers is a race condition in any multi-user system |
| 2 | No UNIQUE constraint on usernames — seed data even contained a duplicate | Fixed the duplicate row, added UNIQUE constraints to both credentials tables | Constraints exist to catch exactly the mistakes humans make; the duplicate proved it |
| 3 | `CHECK (AppointmentDate >= GETDATE())` — non-deterministic constraint | Dropped it; the rule now lives in the `ScheduleAppointment` procedure with THROW | A GETDATE() check re-evaluates on every UPDATE, so old rows become permanently un-updatable |
| 4 | Archived half of the UNION view concatenated names without a space | View recreated with consistent formatting; review join also corrected to join on AppointmentID | Small, but visible in every report built on the view |
| 5 | `Reviews.DoctorID` had no foreign key | Added FK to Doctors | Orphaned reviews were silently possible |

## Interview notes to self

- **Trigger scoping**: always operate on `inserted`/`deleted`, never on the whole table.
- **Non-deterministic constraints**: business rules involving "now" belong in procedures
  or the application layer, not CHECK constraints.
- **Why unsalted SHA-256 is weak**: fast hashes + no salt = rainbow-table risk; real
  systems use bcrypt/Argon2 with per-user salts.
- **Why the archive pattern**: keeps the hot table small; the UNION view gives reporting
  a single surface over both.
