#!/usr/bin/env node

/**
 * Stitch Screen Downloader
 * 
 * Fetches HTML code and screenshot assets for the SmartMark project from Google Stitch MCP API.
 * Usage:
 *   export STITCH_API_KEY="your-api-key" # or export STITCH_ACCESS_TOKEN="your-oauth-token"
 *   node scripts/download_stitch_screens.mjs
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROJECT_ID = "10062615496275032549";
const MCP_ENDPOINT = "https://stitch.googleapis.com/mcp";

const SCREENS = [
  { id: "a2ebb6f16f6c402da000ef0e370dd559", title: "SmartMark Web - Item Difficulty & Question Analysis", slug: "01_item_difficulty_analysis" },
  { id: "bf82f1e519a9452eb25de4a7a530a292", title: "SmartMark - Student Roster with Split-Screen Audit", slug: "02_student_roster_split_audit" },
  { id: "13c55d8751b74cb98deef55c0159844a", title: "SmartMark Web - Assessment Analytics Portal", slug: "03_assessment_analytics_portal" },
  { id: "16bff46457d64714b9d94fc1fc94a908", title: "Top-down realistic desk view of exam paper", slug: "04_desk_handwritten_exam_paper" },
  { id: "6a26e976742b4280ae926eced0516fba", title: "SmartMark - Instant Paper Result Verification", slug: "05_instant_result_verification" },
  { id: "cd97b65c3564461191d79ab5c67b89f6", title: "SmartMark - Answer Sheet Auto-Capture", slug: "06_answer_sheet_auto_capture" },
  { id: "1e823e8c3e3f46218f5cc2b8be0d0cbd", title: "SmartMark - Teacher Assessment Home", slug: "07_teacher_assessment_home" }
];

const OUTPUT_DIR = path.resolve(__dirname, "../stitch_output");

async function main() {
  const apiKey = process.env.STITCH_API_KEY;
  const accessToken = process.env.STITCH_ACCESS_TOKEN;

  const headers = {
    "Content-Type": "application/json"
  };

  if (apiKey) {
    headers["X-Goog-Api-Key"] = apiKey;
    console.log("Using STITCH_API_KEY for authentication.");
  } else if (accessToken) {
    headers["Authorization"] = `Bearer ${accessToken}`;
    console.log("Using STITCH_ACCESS_TOKEN for authentication.");
  } else {
    console.warn("⚠️ No STITCH_API_KEY or STITCH_ACCESS_TOKEN found in environment.");
    console.warn("Google Stitch MCP API requires authentication.");
    console.warn("You can generate an API key at https://stitch.withgoogle.com/settings or export from Stitch UI.");
  }

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  console.log(`\nFetching ${SCREENS.length} screens for Project ${PROJECT_ID}...\n`);

  for (const screen of SCREENS) {
    const screenResource = `projects/${PROJECT_ID}/screens/${screen.id}`;
    console.log(`[Screen] ${screen.slug}: ${screen.title}`);
    console.log(`  Resource: ${screenResource}`);

    const payload = {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: {
        name: "get_screen",
        arguments: {
          name: screenResource
        }
      }
    };

    try {
      const res = await fetch(MCP_ENDPOINT, {
        method: "POST",
        headers,
        body: JSON.stringify(payload)
      });

      const data = await res.json();

      if (data.result?.isError) {
        console.error(`  ❌ Error: ${JSON.stringify(data.result.content)}`);
        continue;
      }

      const screenDir = path.join(OUTPUT_DIR, screen.slug);
      fs.mkdirSync(screenDir, { recursive: true });

      const screenData = data.result;
      const htmlUrl = screenData?.htmlCode?.downloadUrl;
      const imageUrl = screenData?.screenshot?.downloadUrl;

      if (htmlUrl) {
        console.log(`  Downloading HTML: ${htmlUrl}`);
        const htmlRes = await fetch(htmlUrl);
        if (htmlRes.ok) {
          const html = await htmlRes.text();
          fs.writeFileSync(path.join(screenDir, "screen.html"), html);
          console.log(`  Saved screen.html`);
        }
      }

      if (imageUrl) {
        console.log(`  Downloading Screenshot: ${imageUrl}`);
        const imgRes = await fetch(imageUrl);
        if (imgRes.ok) {
          const buffer = Buffer.from(await imgRes.arrayBuffer());
          fs.writeFileSync(path.join(screenDir, "screenshot.png"), buffer);
          console.log(`  Saved screenshot.png`);
        }
      }
    } catch (err) {
      console.error(`  Failed to fetch ${screen.slug}:`, err.message);
    }
  }

  console.log("\nDone.");
}

main().catch(console.error);
