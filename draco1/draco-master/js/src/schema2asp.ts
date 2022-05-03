import { Schema } from './data2schema';

export default function schema2asp(schema: Schema): string[] {
  if (!schema) {
    throw Error('No data has been prepared');
  }

  const stats = schema.stats;
  const decl = [`num_rows(${schema.size}).\n`];

  Object.keys(stats).forEach((field, i) => {
    const fieldName = `\"${field}\"`;
    const fieldStats = stats[field];
    const fieldType = `fieldtype(${fieldName},${fieldStats.type}).`;
    const cardinality = `cardinality(${fieldName}, ${fieldStats.distinct}).`;

    decl.push(`${fieldType}\n${cardinality}`);
  });

  return decl;
}
