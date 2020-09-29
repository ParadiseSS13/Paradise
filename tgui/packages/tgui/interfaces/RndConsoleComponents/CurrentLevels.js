import { useBackend } from "../../backend";

export const CurrentLevels = (properties, context) => {
  const { data } = useBackend(context);

  const {
    tech_levels,
  } = data;

  return (
    <div>
      <h3>Current Research Levels:</h3>
      {tech_levels.map((techLevel, i) => {
        const { name, level, desc } = techLevel;
        return (
          <>
            {i > 0 ? <hr /> : null}
            <div>{name}</div>
            <div>* Level: {level}</div>
            <div>* Summary: {desc}</div>
          </>
        );
      })}
    </div>
  );
};
