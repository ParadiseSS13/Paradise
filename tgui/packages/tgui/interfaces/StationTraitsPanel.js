import { filterMap } from "common/collections"
import { exhaustiveCheck } from "common/exhaustive"
import { useBackend, useLocalState } from "../backend"
import { Box, Button, Divider, Dropdown, Stack, Tabs } from "../components"
import { Window } from "../layouts"

let Tab

;(function(Tab) {
  Tab[(Tab["SetupFutureStationTraits"] = 0)] = "SetupFutureStationTraits"
  Tab[(Tab["ViewStationTraits"] = 1)] = "ViewStationTraits"
})(Tab || (Tab = {}))

const FutureStationTraitsPage = (props, context) => {
  const { act, data } = useBackend(context)
  const { future_station_traits } = data

  const [selectedTrait, setSelectedTrait] = useLocalState(
    context,
    "selectedFutureTrait",
    null
  )

  const traitsByName = Object.fromEntries(
    data.valid_station_traits.map(trait => {
      return [trait.name, trait.path]
    })
  )

  const traitNames = Object.keys(traitsByName)
  traitNames.sort()

  return (
    <Box>
      <Stack fill>
        <Stack.Item grow>
          <Dropdown
            displayText={!selectedTrait && "Select trait to add..."}
            onSelected={setSelectedTrait}
            options={traitNames}
            selected={selectedTrait}
            width="100%"
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            color="green"
            icon="plus"
            onClick={() => {
              if (!selectedTrait) {
                return
              }

              const selectedPath = traitsByName[selectedTrait]

              let newStationTraits = [selectedPath]
              if (future_station_traits) {
                const selectedTraitPaths = future_station_traits.map(
                  trait => trait.path
                )

                if (selectedTraitPaths.indexOf(selectedPath) !== -1) {
                  return
                }

                newStationTraits = newStationTraits.concat(
                  ...selectedTraitPaths
                )
              }

              act("setup_future_traits", {
                station_traits: newStationTraits
              })
            }}
          >
            Add
          </Button>
        </Stack.Item>
      </Stack>

      <Divider />

      {Array.isArray(future_station_traits) ? (
        future_station_traits.length > 0 ? (
          <Stack vertical fill>
            {future_station_traits.map(trait => (
              <Stack.Item key={trait.path}>
                <Stack fill>
                  <Stack.Item grow>{trait.name}</Stack.Item>

                  <Stack.Item>
                    <Button
                      color="red"
                      icon="times"
                      onClick={() => {
                        act("setup_future_traits", {
                          station_traits: filterMap(
                            future_station_traits,
                            otherTrait => {
                              if (otherTrait.path === trait.path) {
                                return undefined
                              } else {
                                return otherTrait.path
                              }
                            }
                          )
                        })
                      }}
                    >
                      Delete
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        ) : (
          <>
            <Box>No station traits will run next round.</Box>

            <Box>
              <Button
                color="red"
                icon="times"
                tooltip="The next round will roll station traits randomly, just like normal"
                onClick={() => act("clear_future_traits")}
              >
                Run Station Traits Normally
              </Button>
            </Box>
          </>
        )
      ) : (
        <>
          <Box>No future station traits are planned.</Box>

          <Box>
            <Button
              color="red"
              icon="times"
              onClick={() =>
                act("setup_future_traits", {
                  station_traits: []
                })
              }
            >
              Prevent station traits from running next round
            </Button>
          </Box>
        </>
      )}
    </Box>
  )
}

const ViewStationTraitsPage = (props, context) => {
  const { act, data } = useBackend(context)

  return data.current_traits.length > 0 ? (
    <Stack vertical fill>
      {data.current_traits.map(stationTrait => (
        <Stack.Item key={stationTrait.ref}>
          <Stack fill>
            <Stack.Item grow>{stationTrait.name}</Stack.Item>

            <Stack.Item>
              <Button.Confirm
                content="Revert"
                color="red"
                disabled={data.too_late_to_revert || !stationTrait.can_revert}
                tooltip={
                  (!stationTrait.can_revert &&
                    "This trait is not revertable.") ||
                  (data.too_late_to_revert &&
                    "It's too late to revert station traits, the round has already started.")
                }
                icon="times"
                onClick={() =>
                  act("revert", {
                    ref: stationTrait.ref
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  ) : (
    <Box>There are no active station traits.</Box>
  )
}

export const StationTraitsPanel = (props, context) => {
  const [currentTab, setCurrentTab] = useLocalState(
    context,
    "station_traits_tab",
    Tab.ViewStationTraits
  )

  let currentPage

  switch (currentTab) {
    case Tab.SetupFutureStationTraits:
      currentPage = <FutureStationTraitsPage />
      break
    case Tab.ViewStationTraits:
      currentPage = <ViewStationTraitsPage />
      break
    default:
      exhaustiveCheck(currentTab)
  }

  return (
    <Window title="Modify Station Traits" height={500} width={500}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="eye"
            selected={currentTab === Tab.ViewStationTraits}
            onClick={() => setCurrentTab(Tab.ViewStationTraits)}
          >
            View
          </Tabs.Tab>

          <Tabs.Tab
            icon="edit"
            selected={currentTab === Tab.SetupFutureStationTraits}
            onClick={() => setCurrentTab(Tab.SetupFutureStationTraits)}
          >
            Edit
          </Tabs.Tab>
        </Tabs>

        <Divider />

        {currentPage}
      </Window.Content>
    </Window>
  )
}
