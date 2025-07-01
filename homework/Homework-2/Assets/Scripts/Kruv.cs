using UnityEngine;
using UnityEngine.SceneManagement;

public class Kruv : MonoBehaviour
{
    private int kruv;

    Vector2 na4alo;

    [SerializeField]
    int max_kruv;

    [SerializeField]
    GameObject g_hud;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        na4alo = transform.position;
        kruv = max_kruv;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void Vzemi()
    {
        g_hud.GetComponent<Hud>().Pokaji();
    }

    public void Narani()
    {
        if (kruv > 0)
        {
            kruv--;
            g_hud.GetComponent<Hud>().Narani();
        }
        else
        {
            Umri();
        }
    }

    public void Umri()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
