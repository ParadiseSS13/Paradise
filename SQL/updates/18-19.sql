# Updating DB from 15-16, -AffectedArc07
# Finalises feedback2

# Drop old feedback table
DROP TABLE `feedback`;

# Rename feedback_2 to feedback
RENAME TABLE `feedback_2` TO `feedback`;
