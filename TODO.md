# Admin Panel White Screen Fix

## Current Status
- [x] Diagnosed issue: Firestore permission-denied + poor loading/error UI logic
- [x] Created plan and got approval

## Steps to Complete
1. [ ] Fix `lib/screens/admin/admin_dashboard_screen.dart`:
   - Update loading condition to `admin.isLoading`
   - Ensure error UI always shows if `admin.error != null`
   - Fix all `withOpacity` deprecations → `withValues(alpha: )`
   - Add fallback empty state
2. [ ] Test admin panel (hot restart)
3. [ ] If needed: Update Firebase Firestore Rules
4. [ ] Verify all admin functionality restored

## Notes
- Likely cause: Firestore rules blocking `users` collection read
- Temporary fix: UI improvements for better error visibility