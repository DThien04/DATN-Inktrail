ALTER TABLE "chapter_comments"
ADD COLUMN "parent_id" TEXT NULL;

ALTER TABLE "chapter_comments"
ADD CONSTRAINT "chapter_comments_parent_id_fkey"
FOREIGN KEY ("parent_id")
REFERENCES "chapter_comments"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE INDEX "chapter_comments_chapter_id_parent_id_created_at_idx"
ON "chapter_comments"("chapter_id", "parent_id", "created_at");

CREATE INDEX "chapter_comments_parent_id_created_at_idx"
ON "chapter_comments"("parent_id", "created_at");