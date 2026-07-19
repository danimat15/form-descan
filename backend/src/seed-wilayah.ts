import fs from 'fs';
import path from 'path';
import { db } from './db/drizzle.js';
import { wilayahSangihe } from './db/schema.js';
async function main() {
  console.log('=============================================');
  console.log('Seeding Wilayah Sangihe dari CSV...');
  console.log('=============================================');

  try {
    const csvPath = path.join(process.cwd(), 'wilayah/nama_wilayah_sangihe.csv');
    if (!fs.existsSync(csvPath)) {
      throw new Error(`File CSV tidak ditemukan di: ${csvPath}`);
    }

    const content = fs.readFileSync(csvPath, 'utf-8');
    const lines = content.split(/\r?\n/);
    
    // Header: id_subsls,kd_prov,kd_kab,kd_kec,kd_desa,kd_sls,nama_prov,nama_kab,nama_kec,nama_desa,nama_sls,kd_pos
    const dataLines = lines.slice(1);
    const records = [];
    
    for (let i = 0; i < dataLines.length; i++) {
      const line = dataLines[i];
      if (!line.trim()) continue;
      
      const parts = line.split(',');
      if (parts.length < 12) {
        console.warn(`Baris ${i + 2} tidak valid (kurang dari 12 kolom), dilewati: ${line}`);
        continue;
      }
      
      records.push({
        idSubsls: parts[0].trim(),
        kdProv: parts[1].trim(),
        kdKab: parts[2].trim(),
        kdKec: parts[3].trim(),
        kdDesa: parts[4].trim(),
        kdSls: parts[5].trim(),
        namaProv: parts[6].trim(),
        namaKab: parts[7].trim(),
        namaKec: parts[8].trim(),
        namaDesa: parts[9].trim(),
        namaSls: parts[10].trim(),
        kdPos: parts[11].trim(),
      });
    }
    
    console.log(`Berhasil mem-parsing ${records.length} data wilayah.`);
    
    console.log('Membersihkan data wilayah lama di database...');
    await db.delete(wilayahSangihe);
    
    console.log('Memasukkan data wilayah baru...');
    // Lakukan batch insert (masing-masing 100 baris) agar tidak melebihi batas parameter query
    const batchSize = 100;
    for (let i = 0; i < records.length; i += batchSize) {
      const batch = records.slice(i, i + batchSize);
      await db.insert(wilayahSangihe).values(batch);
      console.log(`✓ Berhasil memasukkan data ke-${i + 1} sampai ${Math.min(i + batchSize, records.length)}`);
    }
    
    console.log('=============================================');
    console.log('Seeding Wilayah Sangihe Berhasil!');
    console.log('=============================================');
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Seeding gagal!');
    console.error(error);
    console.log('=============================================');
    process.exit(1);
  }
}

main();
