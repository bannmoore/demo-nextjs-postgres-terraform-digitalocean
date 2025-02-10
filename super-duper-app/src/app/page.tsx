import { getThings } from "@/database";

export default async function Home() {
  const things = await getThings();

  return (
    <div className="items-center justify-items-center p-8">
      <main>
        <div>Here are some things:</div>
        <ul>
          {things.map((thing) => (
            <li key={thing.id}>{thing.name}</li>
          ))}
        </ul>
      </main>
    </div>
  );
}

// Reference: https://nextjs.org/docs/app/building-your-application/data-fetching/fetching
export const dynamic = "force-dynamic";
