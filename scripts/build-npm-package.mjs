import assert from 'node:assert/strict';
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = resolve(fileURLToPath(new URL('..', import.meta.url)));
const output = join(repo, 'dist', 'skills');
const excluded = new Set(['.git', '.github', 'deprecated', 'dist', 'in-progress', 'node_modules', 'personal', 'scripts']);

function skillDirectories(directory) {
  if (excluded.has(basename(directory))) return [];
  if (existsSync(join(directory, 'SKILL.md'))) return [directory];

  return readdirSync(directory, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && !entry.isSymbolicLink() && !excluded.has(entry.name))
    .flatMap((entry) => skillDirectories(join(directory, entry.name)));
}

function skillName(directory) {
  const text = readFileSync(join(directory, 'SKILL.md'), 'utf8');
  const frontmatter = text.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  assert.ok(frontmatter, `${directory}: missing YAML frontmatter`);
  const field = frontmatter[1].match(/^name:\s*(.+?)\s*$/m);
  assert.ok(field, `${directory}: missing name field`);
  const name = field[1].replace(/^['"]|['"]$/g, '');
  assert.match(name, /^[a-z0-9-]+$/, `${directory}: invalid skill name ${name}`);
  return name;
}

const roots = readdirSync(repo, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && !entry.isSymbolicLink() && !entry.name.startsWith('.') && !excluded.has(entry.name))
  .map((entry) => join(repo, entry.name));
const skills = roots.flatMap(skillDirectories);
assert.ok(skills.length > 0, 'no shippable skills found');

rmSync(output, { recursive: true, force: true });
mkdirSync(output, { recursive: true });

const names = new Set();
for (const source of skills) {
  const name = skillName(source);
  assert.ok(!names.has(name), `duplicate skill name: ${name}`);
  names.add(name);
  const destination = join(output, name);
  cpSync(source, destination, { recursive: true });
  assert.ok(existsSync(join(destination, 'SKILL.md')), `${name}: packaged SKILL.md is missing`);
}

assert.equal(readdirSync(output).length, skills.length, 'package output does not match discovered skill count');
console.log(`Prepared ${skills.length} skills in dist/skills`);
