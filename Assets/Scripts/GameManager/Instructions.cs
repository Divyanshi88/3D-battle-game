using UnityEngine;
using UnityEngine.UI;

public class Instructions : MonoBehaviour
{
    public Text instructionText;

    void Start()
    {
        instructionText.text = "Controls: Move = Arrow Keys | Jump = Space | Attack = F";
    }
}
