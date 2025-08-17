import { zip } from 'common/collections';
import { useEffect, useRef, useState } from 'react';
import { Box, Icon, Section, Tabs } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AtmosGraphMonitor = () => {
  const { data } = useBackend();
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return (
          <AtmosGraphPage
            data={data}
            info="Интервал записи T = 60 с. | Интервал между записями t = 3 с."
            pressureListName="pressure_history"
            temperatureListName="temperature_history"
          />
        );
      case 1:
        return (
          <AtmosGraphPage
            data={data}
            info="Интервал записи T = 10 мин. | Интервал между записями t = 30 с."
            pressureListName="long_pressure_history"
            temperatureListName="long_temperature_history"
          />
        );

      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };
  const getWindowHeight = (sensorsLenght) => {
    switch (sensorsLenght) {
      case 0:
        return 180;
      case 1:
        return 350;
      case 2:
        return 590;
      case 3:
        return 830;
      default:
        return 870;
    }
  };
  return (
    <Window width={700} height={getWindowHeight(Object.keys(data.sensors).length)}>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab key="View" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
              <Icon name="area-chart" /> Текущие
            </Tabs.Tab>
            <Tabs.Tab key="History" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              <Icon name="bar-chart" /> История
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
          {Object.keys(data.sensors).length === 0 && (
            <Box pt={2} textAlign={'center'} textColor={'gray'} bold fontSize={1.3}>
              Подключите gas sensor или meter с помощью multitool
            </Box>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};

const AtmosGraphPage = ({ data, info, pressureListName, temperatureListName }) => {
  let sensors_list = data.sensors || {};

  const getLastReading = (sensor, listName) => sensors_list[sensor][listName].slice(-1)[0];
  const getMinReading = (sensor, listName) => Math.min(...sensors_list[sensor][listName]);
  const getMaxReading = (sensor, listName) => Math.max(...sensors_list[sensor][listName]);
  const getDataToSensor = (sensor, listName) => sensors_list[sensor][listName].map((value, index) => [index, value]);

  return (
    <Box>
      <Section color={'gray'}>{info}</Section>
      {Object.keys(sensors_list).map((s) => (
        <Section key={s} title={s}>
          <Section px={2}>
            {/* ТЕМПЕРАТУРА */}
            {temperatureListName in sensors_list[s] && (
              <Box mb={4}>
                <Box>
                  {'Температура: ' +
                    toFixed(getLastReading(s, temperatureListName), 0) +
                    'К (MIN: ' +
                    toFixed(getMinReading(s, temperatureListName), 0) +
                    'К;' +
                    ' MAX: ' +
                    toFixed(getMaxReading(s, temperatureListName), 0) +
                    'К)'}
                </Box>
                <Section fill height={5} mt={1}>
                  <AtmosChart
                    fillPositionedParent
                    data={getDataToSensor(s, temperatureListName)}
                    rangeX={[0, getDataToSensor(s, temperatureListName).length - 1]}
                    rangeY={[getMinReading(s, temperatureListName) - 10, getMaxReading(s, temperatureListName) + 5]}
                    strokeColor="rgba(219, 40, 40, 1)"
                    fillColor="rgba(219, 40, 40, 0.1)"
                    horizontalLinesCount={2}
                    verticalLinesCount={getDataToSensor(s, temperatureListName).length - 2}
                    labelViewBoxSize={400}
                  />
                </Section>
              </Box>
            )}

            {/* ДАВЛЕНИЕ */}
            {pressureListName in sensors_list[s] && (
              <Box mb={-1}>
                <Box>
                  {'Давление: ' +
                    toFixed(getLastReading(s, pressureListName), 0) +
                    'кПа (MIN: ' +
                    toFixed(getMinReading(s, pressureListName), 0) +
                    'кПа;' +
                    ' MAX: ' +
                    toFixed(getMaxReading(s, pressureListName), 0) +
                    'кПа)'}
                </Box>
                <Section fill height={5} mt={1}>
                  <AtmosChart
                    fillPositionedParent
                    data={getDataToSensor(s, pressureListName)}
                    rangeX={[0, getDataToSensor(s, pressureListName).length - 1]}
                    rangeY={[getMinReading(s, pressureListName) - 10, getMaxReading(s, pressureListName) + 5]}
                    strokeColor="rgba(40, 219, 40, 1)"
                    fillColor="rgba(40, 219, 40, 0.1)"
                    horizontalLinesCount={2}
                    verticalLinesCount={getDataToSensor(s, pressureListName).length - 2}
                    labelViewBoxSize={400}
                  />
                </Section>
              </Box>
            )}
          </Section>
        </Section>
      ))}
    </Box>
  );
};

// Ниже находится код вдохновленный компонентом CHART.JS
// К удалению, если будут приняты изменения в официальном компоненте

const normalizeData = (data, scale, rangeX, rangeY) => {
  if (data.length === 0) {
    return [];
  }

  const zipped = zip(...data);
  const min = zipped.map((p) => Math.min(...p));
  const max = zipped.map((p) => Math.max(...p));

  if (rangeX !== undefined) {
    min[0] = rangeX[0];
    max[0] = rangeX[1];
  }
  if (rangeY !== undefined) {
    min[1] = rangeY[0];
    max[1] = rangeY[1];
  }
  const normalized = data.map((point) =>
    zip(point, min, max, scale).map(([value, min, max, scale]) => ((value - min) / (max - min)) * scale)
  );

  return normalized;
};

const dataToPolylinePoints = (data) => {
  let points = '';
  for (let i = 0; i < data.length; i++) {
    const point = data[i];
    points += point[0] + ',' + point[1] + ' ';
  }
  return points;
};

function AtmosChart(props) {
  const {
    data = [],
    rangeX,
    rangeY,
    fillColor = 'none',
    strokeColor = '#ffffff',
    strokeWidth = 2,
    horizontalLinesCount = 0,
    verticalLinesCount = 0,
    gridColor = 'rgba(255, 255, 255, 0.1)',
    gridWidth = 2,
    pointTextColor = 'rgba(255, 255, 255, 0.8)',
    pointTextSize = '0.8em',
    labelViewBoxSize = 0,
    ...rest
  } = props;

  const ref = useRef < HTMLDivElement > null;
  const [viewBox, setViewBox] = useState < [number, number] > [400, 800];
  const handleResize = () => {
    const element = ref.current;
    if (!element) {
      return;
    }

    setViewBox([element.offsetWidth, element.offsetHeight]);
  };

  useEffect(() => {
    window.addEventListener('resize', handleResize);
    handleResize();
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const normalized = normalizeData(data, viewBox, rangeX, rangeY);
  // Push data outside viewBox and form a fillable polygon
  if (normalized.length > 0) {
    const first = normalized[0];
    const last = normalized[normalized.length - 1];
    normalized.push([viewBox[0] + strokeWidth, last[1]]);
    normalized.push([viewBox[0] + strokeWidth, -strokeWidth]);
    normalized.push([-strokeWidth, -strokeWidth]);
    normalized.push([-strokeWidth, first[1]]);
  }
  const points = dataToPolylinePoints(normalized);
  return (
    <Box ref={ref} position="relative" {...rest}>
      {(props) => (
        <div ref={ref} {...props}>
          <svg viewBox={`0 0 ${viewBox[0]} ${viewBox[1]}`}>
            {/* Горизонтальные линии сетки */}
            {Array.from({ length: horizontalLinesCount }).map((_, index) => (
              <line
                key={`horizontal-line-${index}`}
                x1={0}
                y1={(index + 1) * (viewBox[1] / (horizontalLinesCount + 1))}
                x2={viewBox[0]}
                y2={(index + 1) * (viewBox[1] / (horizontalLinesCount + 1))}
                stroke={gridColor}
                strokeWidth={gridWidth}
              />
            ))}
            {/* Вертикальные линии сетки */}
            {Array.from({ length: verticalLinesCount }).map((_, index) => (
              <line
                key={`vertical-line-${index}`}
                x1={(index + 1) * (viewBox[0] / (verticalLinesCount + 1))}
                y1={0}
                x2={(index + 1) * (viewBox[0] / (verticalLinesCount + 1))}
                y2={viewBox[1]}
                stroke={gridColor}
                strokeWidth={gridWidth}
              />
            ))}
            {/* Полилиния (заливка) графика */}
            <polyline transform={`scale(1, -1) translate(0, -${viewBox[1]})`} fill={fillColor} points={points} />
            {/* Линия графика */}
            {data.map((point, index) => {
              if (index === 0) return null;
              return (
                <line
                  key={`line-${index}`}
                  x1={normalized[index - 1][0]}
                  y1={viewBox[1] - normalized[index - 1][1]}
                  x2={normalized[index][0]}
                  y2={viewBox[1] - normalized[index][1]}
                  stroke={strokeColor}
                  strokeWidth={strokeWidth}
                />
              );
            })}
            {/* Точки */}
            {data.map((point, index) => (
              <circle
                key={`point-${index}`}
                cx={normalized[index][0]}
                cy={viewBox[1] - normalized[index][1]}
                r={2}
                fill="#ffffff"
                stroke={strokeColor}
                strokeWidth={1}
              />
            ))}
            {/* Значения точек */}
            {data.map(
              (point, index) =>
                viewBox[0] > labelViewBoxSize &&
                index % 2 === 1 && (
                  <text
                    key={`point-text-${index}`}
                    x={normalized[index][0]}
                    y={viewBox[1] - normalized[index][1]}
                    fill={pointTextColor}
                    fontSize={pointTextSize}
                    dy="1em"
                    style={{ textAnchor: 'end' }}
                  >
                    {point[1] !== null ? point[1].toFixed(0) : 'N/A'}
                  </text>
                )
            )}
          </svg>
        </div>
      )}
    </Box>
  );
}
