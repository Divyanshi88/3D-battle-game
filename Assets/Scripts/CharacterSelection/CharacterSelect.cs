using UnityEngine;
using UnityEngine.SceneManagement;

public class CharacterSelect : MonoBehaviour
{
    public void SelectHero()
    {
        PlayerPrefs.SetString("SelectedCharacter", "Hero");
        SceneManager.LoadScene("GameScene");
    }

    public void SelectEnemy()
    {
        PlayerPrefs.SetString("SelectedCharacter", "Enemy");
        SceneManager.LoadScene("GameScene");
    }
}
