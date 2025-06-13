using UnityEngine;

public class CharacterLoader : MonoBehaviour
{
    public GameObject heroPrefab;
    public GameObject enemyPrefab;
    public Transform spawnPoint;

    void Start()
    {
        string selectedCharacter = PlayerPrefs.GetString("SelectedCharacter");
        GameObject characterToSpawn = null;

        if (selectedCharacter == "Hero")
        {
            characterToSpawn = Instantiate(heroPrefab, spawnPoint.position, Quaternion.identity);
        }
        else if (selectedCharacter == "Enemy")
        {
            characterToSpawn = Instantiate(enemyPrefab, spawnPoint.position, Quaternion.identity);
        }

        if (characterToSpawn != null)
        {
            characterToSpawn.AddComponent<Player.PlayerController>(); // Make sure to use the correct namespace
        }
    }
}
